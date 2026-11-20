# Linux Admin Toolkit

Small, readable Bash tools for everyday Linux administration. Built in public over 30 days.

## Tools
| Script | What it does |
|---|---|
| `scripts/health-check.sh` | CPU, memory, disk, and uptime report with threshold warnings |
| `scripts/service-check.sh` | Checks one or more systemd services; exit code 2 if any are down |
| `scripts/log-analyzer.sh` | Summarizes errors by service and failed logins from journald |
| `scripts/system-monitor.sh` | Snapshot of load, memory, and top processes; can repeat on an interval |

## Usage
    ./scripts/health-check.sh
    DISK_WARN=70 MEM_WARN=60 ./scripts/health-check.sh

    ./scripts/service-check.sh sshd NetworkManager

    ./scripts/log-analyzer.sh        # last 24 hours
    ./scripts/log-analyzer.sh 1      # last 1 hour

    ./scripts/system-monitor.sh          # one snapshot
    ./scripts/system-monitor.sh 5 12     # every 5 seconds, 12 times
    TOP_N=10 ./scripts/system-monitor.sh

## Exit codes
| Script | 0 | 1 | 2 |
|---|---|---|---|
| `health-check.sh` | healthy | at least one warning | — |
| `service-check.sh` | all running | usage error | at least one not running |
| `log-analyzer.sh` | done | usage error | — |
| `system-monitor.sh` | done | usage error | — |

## Example output (log-analyzer)
    == LOG SUMMARY: last 1 hour(s) ==

    -- Error-level messages by service (top 10) --
          1 david

    -- Failed authentication attempts --
    Count: 0

    -- Last 5 error lines --
    Nov 19 12:07:03 omar1 david[500657]: toolkit-test: simulated error

## What I learned
- Exit codes are how scripts talk to other tools.
- ShellCheck catches mistakes before they reach production.

## Tested on
Omarchy (Arch-based), Bash 5.x
