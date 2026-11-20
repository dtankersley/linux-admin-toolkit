#!/usr/bin/env bash
# backup.sh - timestamped tar.gz backups of a directory, keeping the newest N
# Usage: backup.sh <source_dir> [backup_dir]
#   backup_dir defaults to $BACKUP_DIR, or ~/backups
#   KEEP=N sets how many backups of this source to keep (default 7)
# Exit codes: 0 ok, 1 usage error, 2 backup or verify failed
set -uo pipefail

usage() { echo "Usage: $0 <source_dir> [backup_dir]" >&2; exit 1; }

(( $# >= 1 && $# <= 2 )) || usage
SRC=${1%/}
DEST=${2:-${BACKUP_DIR:-$HOME/backups}}
KEEP=${KEEP:-7}

[[ -d "$SRC" ]] || { echo "Error: '$SRC' is not a directory" >&2; exit 1; }
[[ "$KEEP" =~ ^[1-9][0-9]*$ ]] || { echo "Error: KEEP must be a positive number" >&2; exit 1; }

mkdir -p "$DEST" || { echo "Error: cannot create '$DEST'" >&2; exit 2; }

name=$(basename "$(realpath "$SRC")")
stamp=$(date +%Y%m%d-%H%M%S)
archive="${DEST}/${name}-${stamp}.tar.gz"

echo "== BACKUP: ${SRC} -> ${archive} =="

# -C keeps paths inside the archive relative (name/...), not absolute
if ! tar -czf "$archive" -C "$(dirname "$(realpath "$SRC")")" "$name"; then
    echo "FAILED: tar exited with an error" >&2
    rm -f "$archive"
    exit 2
fi

# Verify the archive can be read back before trusting it
if ! tar -tzf "$archive" > /dev/null; then
    echo "FAILED: archive did not verify" >&2
    rm -f "$archive"
    exit 2
fi

echo "Created: $(du -h "$archive" | cut -f1)  $(tar -tzf "$archive" | wc -l) entries"

# Rotation: keep the newest $KEEP archives for this source, delete the rest.
# The strict pattern only matches name-YYYYMMDD-HHMMSS.tar.gz, and globs sort
# alphabetically, which for these timestamps means oldest first.
shopt -s nullglob
backups=("${DEST}/${name}"-[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9][0-9][0-9].tar.gz)
excess=$(( ${#backups[@]} - KEEP ))
for (( i = 0; i < excess; i++ )); do
    rm -f -- "${backups[i]}" && echo "Rotated out: $(basename "${backups[i]}")"
done

kept=$(( ${#backups[@]} - (excess > 0 ? excess : 0) ))
echo "Backups kept for '${name}': ${kept} (KEEP=${KEEP})"
