#!/usr/bin/env bash
# health-check.sh - quick Linux health report with threshold warnings
set -euo pipefail

DISK_WARN=${DISK_WARN:-80}   # percent used
MEM_WARN=${MEM_WARN:-80}     # percent used
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
    exit 1
fi
echo "All checks passed."
