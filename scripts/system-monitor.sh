#!/usr/bin/env bash
# system-monitor.sh - snapshot of what is using the machine right now
# Usage: system-monitor.sh [interval_seconds] [count]
#   No arguments: print one snapshot and exit.
#   With interval: repeat every N seconds, COUNT times (default: until Ctrl+C).
# Exit codes: 0 ok, 1 usage error
set -uo pipefail

INTERVAL=${1:-0}
COUNT=${2:-0}
TOP_N=${TOP_N:-5}

for arg in "$INTERVAL" "$COUNT" "$TOP_N"; do
    if ! [[ "$arg" =~ ^[0-9]+$ ]]; then
        echo "Usage: $0 [interval_seconds] [count]" >&2
        exit 1
    fi
done

section() { printf '\n-- %s --\n' "$1"; }

snapshot() {
    printf '== SYSTEM MONITOR: %s on %s ==\n' "$(date '+%F %T')" "$(hostname)"

    section "Load (1/5/15 min) vs CPUs"
    echo "$(cut -d' ' -f1-3 /proc/loadavg)   (CPUs: $(nproc))"

    section "Memory"
    free -h | awk 'NR==1 || /^Mem:/ || /^Swap:/'

    section "Top ${TOP_N} processes by CPU"
    ps -eo pid,user,%cpu,%mem,comm --sort=-%cpu | head -n $((TOP_N + 1))

    section "Top ${TOP_N} processes by memory"
    ps -eo pid,user,%cpu,%mem,comm --sort=-%mem | head -n $((TOP_N + 1))
}

if (( INTERVAL == 0 )); then
    snapshot
    exit 0
fi

runs=0
while true; do
    clear 2>/dev/null || true
    snapshot
    runs=$((runs + 1))
    if (( COUNT > 0 && runs >= COUNT )); then
        break
    fi
    sleep "$INTERVAL"
done
