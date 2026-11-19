#!/usr/bin/env bash
# log-analyzer.sh - summarize recent errors and failed logins from journald
# Usage: log-analyzer.sh [hours]   (default 24)
set -uo pipefail

HOURS=${1:-24}
if ! [[ "$HOURS" =~ ^[0-9]+$ ]]; then
    echo "Usage: $0 [hours]" >&2
    exit 1
fi
SINCE="${HOURS} hours ago"

echo "== LOG SUMMARY: last ${HOURS} hour(s) =="

echo
echo "-- Error-level messages by service (top 10) --"
journalctl --since "$SINCE" -p err --no-pager -o short 2>/dev/null \
    | awk 'NF >= 5 && $0 !~ /^-- / {print $5}' \
    | sed 's/\[[0-9]*\]:$//; s/:$//' \
    | sort | uniq -c | sort -rn | head -10

echo
echo "-- Failed authentication attempts --"
fail_count=$(journalctl --since "$SINCE" --no-pager 2>/dev/null \
    | grep -Ei 'authentication failure|failed password' | wc -l)
echo "Count: ${fail_count}"

echo
echo "-- Last 5 error lines --"
journalctl --since "$SINCE" -p err --no-pager 2>/dev/null | tail -5
