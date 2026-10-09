#!/bin/sh
DIR="$(cd "$(dirname "$0")" && pwd)"
export PATH="$DIR:$PATH"
export DYLD_LIBRARY_PATH="$DIR/lib64:$DYLD_LIBRARY_PATH"
if [ -f "$DIR/arut" ] && [ -x "$DIR/arut" ]; then
    "$DIR/arut" "$@"
else
    echo "[ERROR] arut native binary not found."
fi
