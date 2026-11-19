#!/usr/bin/env bash
# service-check.sh - report whether one or more systemd services are running
# Usage: service-check.sh <service> [service...]
# Exit codes: 0 all running, 1 usage error, 2 at least one not running
set -uo pipefail

if (( $# == 0 )); then
    echo "Usage: $0 <service> [service...]" >&2
    exit 1
fi

failed=0
for svc in "$@"; do
    if systemctl is-active --quiet "$svc"; then
        printf '%-25s RUNNING\n' "$svc"
    else
        printf '%-25s NOT RUNNING\n' "$svc"
        failed=$((failed + 1))
    fi
done

(( failed == 0 )) || exit 2
