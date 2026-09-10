#!/usr/bin/env bash
set -Eeuo pipefail

# Astra disposable Restic restore drill.
#
# Creates a temporary repository and disposable data only.
# It does not access the live Astra backup repository.

required_commands=(
    restic
    sha256sum
    mktemp
    base64
    diff
    find
    sort
    xargs
    head
)

for command in "${required_commands[@]}"; do
    if ! command -v "$command" >/dev/null 2>&1; then
        echo "Required command not found: $command" >&2
        exit 1
    fi
done

WORKDIR="$(mktemp -d -t astra-restic-drill.XXXXXX)"
SOURCE_DIR="$WORKDIR/source"
RESTORE_ROOT="$WORKDIR/restore"
REPOSITORY="$WORKDIR/repository"
PASSWORD_FILE="$WORKDIR/restic-password"
SOURCE_HASHES="$WORKDIR/source.sha256"
RESTORED_HASHES="$WORKDIR/restored.sha256"

cleanup() {
    rm -rf -- "$WORKDIR"
}
trap cleanup EXIT

mkdir -p "$SOURCE_DIR/config" "$SOURCE_DIR/data" "$RESTORE_ROOT"

printf '%s\n' "astra recovery drill" > "$SOURCE_DIR/README.txt"
printf '%s\n' "service=example" "environment=lab" > "$SOURCE_DIR/config/service.conf"
printf '%s\n' "record-001" "record-002" "record-003" > "$SOURCE_DIR/data/example-data.txt"

(
    cd "$SOURCE_DIR"
    find . -type f -print0 | sort -z | xargs -0 sha256sum
) > "$SOURCE_HASHES"

# This password protects only the temporary repository created by this drill.
umask 077
head -c 48 /dev/urandom | base64 > "$PASSWORD_FILE"

export RESTIC_PASSWORD_FILE="$PASSWORD_FILE"
export RESTIC_REPOSITORY="$REPOSITORY"

echo "[1/6] Initialising temporary Restic repository"
restic init >/dev/null

echo "[2/6] Backing up disposable source data"
restic backup "$SOURCE_DIR" --tag astra-recovery-drill >/dev/null

echo "[3/6] Checking temporary repository integrity"
restic check

echo "[4/6] Simulating loss of disposable source data"
rm -rf -- "$SOURCE_DIR"

echo "[5/6] Restoring the latest snapshot to an isolated target"
restic restore latest --target "$RESTORE_ROOT" >/dev/null

# Restic preserves the original absolute path beneath the restore target.
RESTORED_SOURCE="$RESTORE_ROOT$SOURCE_DIR"

if [[ ! -d "$RESTORED_SOURCE" ]]; then
    echo "Recovery drill FAILED: expected restore directory was not created." >&2
    exit 1
fi

(
    cd "$RESTORED_SOURCE"
    find . -type f -print0 | sort -z | xargs -0 sha256sum
) > "$RESTORED_HASHES"

echo "[6/6] Comparing original and restored SHA-256 checksums"
if ! diff -u "$SOURCE_HASHES" "$RESTORED_HASHES"; then
    echo "Recovery drill FAILED: restored checksums differ." >&2
    exit 1
fi

echo
echo "Recovery drill PASSED."
echo "The temporary repository check succeeded and restored checksums match."
echo "This validates only the disposable drill; no live Astra recovery is implied."
