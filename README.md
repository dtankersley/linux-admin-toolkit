# Linux Admin Toolkit

Small, readable Bash tools for everyday Linux administration. Built in public over 30 days.

## Tools
| Script | What it does |
|---|---|
| `scripts/health-check.sh` | CPU, memory, disk, and uptime report with threshold warnings |

## Usage
    ./scripts/health-check.sh
    DISK_WARN=70 MEM_WARN=60 ./scripts/health-check.sh

Exit code 0 means healthy, 1 means at least one warning.

## What I learned
- Exit codes are how scripts talk to other tools.
- ShellCheck catches mistakes before they reach production.

## Tested on
Omarchy (Arch-based), Bash 5.x

| `scripts/service-check.sh` | Checks one or more systemd services; exit code 2 if any are down |
| `scripts/log-analyzer.sh` | Summarizes errors by service and failed logins from journald |

Example output:
== LOG SUMMARY: last 1 hour(s) ==

-- Error-level messages by service (top 10) --
      1 david

-- Failed authentication attempts --
Count: 0

-- Last 5 error lines --
Nov 19 12:07:03 omar1 david[500657]: toolkit-test: simulated error
