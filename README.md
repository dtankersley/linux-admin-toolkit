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
