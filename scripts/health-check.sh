#!/usr/bin/env bash
# health-check.sh - quick Linux health report with threshold warnings
# Usage: health-check.sh   (thresholds: DISK_WARN=N MEM_WARN=N, percent, default 80)
# Exit codes: 0 healthy, 1 usage error, 2 at least one warning
set -euo pipefail

if (( $# > 0 )); then
    echo "Usage: $0   (set DISK_WARN / MEM_WARN to change thresholds)" >&2
    exit 1
fi

DISK_WARN=${DISK_WARN:-80}   # percent used
MEM_WARN=${MEM_WARN:-80}     # percent used
for t in "$DISK_WARN" "$MEM_WARN"; do
    if ! [[ "$t" =~ ^[1-9][0-9]*$ ]] || (( t > 100 )); then
        echo "Error: DISK_WARN and MEM_WARN must be whole numbers from 1 to 100" >&2
        exit 1
    fi
done
warnings=0

section() { printf '\n== %s ==\n' "$1"; }

section "SYSTEM"
echo "Host:    $(hostname)"
echo "User:    $(whoami)"
echo "Kernel:  $(uname -r)"
echo "Uptime:  $(uptime -p)"
echo "CPUs:    $(nproc)"
echo "Load:    $(cut -d' ' -f1-3 /proc/loadavg)"

section "MEMORY"
free -h
mem_used=$(free | awk '/^Mem:/ {printf "%d", $3/$2*100}')
echo "Memory used: ${mem_used}%"
if (( mem_used >= MEM_WARN )); then
    echo "WARNING: memory usage at or above ${MEM_WARN}%"
    warnings=$((warnings + 1))
fi

section "DISK (/)"
df -h /
disk_used=$(df --output=pcent / | tail -1 | tr -dc '0-9')
echo "Disk used: ${disk_used}%"
if (( disk_used >= DISK_WARN )); then
    echo "WARNING: disk usage at or above ${DISK_WARN}%"
    warnings=$((warnings + 1))
fi

section "RESULT"
if (( warnings > 0 )); then
    echo "Completed with ${warnings} warning(s)."
    exit 2
fi
echo "All checks passed."
