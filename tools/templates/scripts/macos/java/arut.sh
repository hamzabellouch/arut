#!/bin/sh
DIR="$(cd "$(dirname "$0")" && pwd)"
export PATH="$DIR:$PATH"
export DYLD_LIBRARY_PATH="$DIR/lib64:$DYLD_LIBRARY_PATH"
if [ -f "$DIR/arut.jar" ]; then
    exec java -jar "$DIR/arut.jar" "$@"
else
    echo "[ERROR] arut.jar not found."
fi
