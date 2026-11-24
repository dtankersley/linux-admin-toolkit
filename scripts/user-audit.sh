#!/usr/bin/env bash
# user-audit.sh - who can log in, who has admin rights, and who logged in lately
# Usage: user-audit.sh            (some checks need root: sudo ./user-audit.sh)
# Exit codes: 0 no findings, 1 usage error, 2 at least one finding
set -uo pipefail

if (( $# > 0 )); then
    echo "Usage: $0   (no arguments; run with sudo for the full audit)" >&2
    exit 1
fi

findings=0
finding() { echo "FINDING: $1"; findings=$((findings + 1)); }
section() { printf '\n== %s ==\n' "$1"; }

# Human accounts are UID_MIN..UID_MAX from /etc/login.defs (usually 1000..60000)
uid_min=$(awk '/^UID_MIN/ {print $2}' /etc/login.defs 2>/dev/null)
uid_max=$(awk '/^UID_MAX/ {print $2}' /etc/login.defs 2>/dev/null)
uid_min=${uid_min:-1000}
uid_max=${uid_max:-60000}

section "HUMAN ACCOUNTS (UID ${uid_min}-${uid_max})"
printf '%-16s %-7s %-24s %s\n' USER UID HOME SHELL
getent passwd | awk -F: -v min="$uid_min" -v max="$uid_max" \
    '$3 >= min && $3 <= max {printf "%-16s %-7s %-24s %s\n", $1, $3, $6, $7}'

section "ACCOUNTS WITH A LOGIN SHELL"
getent passwd | awk -F: '$7 !~ /(nologin|false)$/ {print "  " $1 " (" $7 ")"}'

section "UID 0 (ROOT-EQUIVALENT) ACCOUNTS"
while IFS= read -r user; do
    echo "  ${user}"
    [[ "$user" == "root" ]] || finding "'${user}' has UID 0 and full root rights"
done < <(getent passwd | awk -F: '$3 == 0 {print $1}')

section "ADMIN GROUPS (wheel / sudo)"
for grp in wheel sudo; do
    line=$(getent group "$grp") || continue
    members=$(cut -d: -f4 <<< "$line")
    echo "  ${grp}: ${members:-(no members)}"
done

section "PASSWORD CHECKS"
if [[ -r /etc/shadow ]]; then
    empty=$(awk -F: '$2 == "" {print $1}' /etc/shadow)
    if [[ -n "$empty" ]]; then
        while IFS= read -r user; do
            finding "'${user}' has an empty password (can log in with none)"
        done <<< "$empty"
    else
        echo "  No accounts with empty passwords."
    fi
else
    echo "  Skipped: /etc/shadow needs root. Run: sudo $0"
fi

section "RECENT LOGINS"
if command -v lastlog2 > /dev/null; then
    lastlog2 2>/dev/null | head -15
elif command -v lastlog > /dev/null; then
    lastlog 2>/dev/null | grep -v 'Never logged in' | head -15
elif command -v last > /dev/null; then
    last -n 10 2>/dev/null
else
    echo "  Skipped: no lastlog2, lastlog or last on this system."
fi

section "LOGGED IN NOW"
who || true

section "RESULT"
if (( findings > 0 )); then
    echo "Completed with ${findings} finding(s)."
    exit 2
fi
echo "No findings."
