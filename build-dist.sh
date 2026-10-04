#!/bin/sh
set -e

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$ROOT_DIR"

VERSION="v0.0.1-beta"

echo "========================================================"
echo "  Building ARUT Multi-Platform Release Packages ($VERSION)"
echo "========================================================"

# 1. Build Android Client APK inside application/
echo "[1/3] Building Android APK inside application/..."
cd "$ROOT_DIR/application"
./gradlew assembleRelease
cd "$ROOT_DIR"

# 2. Build Java Relay Server inside relay/java/
echo "[2/3] Building Java Relay Server inside relay/java/..."
cd "$ROOT_DIR/relay/java"
../../application/gradlew assembleRelease
cd "$ROOT_DIR"

# 3. Build Rust Relay Server inside relay/rust/ (if Cargo is installed)
[ -d "$HOME/.cargo/bin" ] && export PATH="$HOME/.cargo/bin:$PATH"
if command -v cargo >/dev/null 2>&1; then
    echo "[3/3] Building Rust Relay Server inside relay/rust/..."
    cd "$ROOT_DIR/relay/rust"
    cargo build --release
    cd "$ROOT_DIR"
else
    echo "[INFO] Cargo not found. Skipping Rust native compilation."
fi

# 4. Assemble and populate dist/ packages
echo ""
echo "Packaging distribution bundles into dist/..."

APK_SRC="$ROOT_DIR/application/app/build/outputs/apk/release/arut-release-unsigned.apk"
[ -f "$ROOT_DIR/application/app/build/outputs/apk/release/arut-release.apk" ] && APK_SRC="$ROOT_DIR/application/app/build/outputs/apk/release/arut-release.apk"

JAR_SRC="$ROOT_DIR/relay/java/build/libs/arut.jar"
TOOLS_ADB_WIN="$ROOT_DIR/tools/adb/windows"
TOOLS_ADB_LINUX="$ROOT_DIR/tools/adb/linux"
TOOLS_ADB_MACOS="$ROOT_DIR/tools/adb/macos"

DIR_WIN_RUST="$ROOT_DIR/dist/windows/arut-rust-win64-$VERSION"
DIR_WIN_JAVA="$ROOT_DIR/dist/windows/arut-java-win64-$VERSION"
DIR_LINUX_RUST="$ROOT_DIR/dist/linux/arut-rust-linux64-$VERSION"
DIR_LINUX_JAVA="$ROOT_DIR/dist/linux/arut-java-linux64-$VERSION"
DIR_MACOS_RUST="$ROOT_DIR/dist/macos/arut-rust-macos64-$VERSION"
DIR_MACOS_JAVA="$ROOT_DIR/dist/macos/arut-java-macos64-$VERSION"
DIR_ALL_RUST="$ROOT_DIR/dist/all-platform/arut-rust-all-$VERSION"
DIR_ALL_JAVA="$ROOT_DIR/dist/all-platform/arut-java-all-$VERSION"

# Clean target directories
rm -rf "$ROOT_DIR/dist"

# ==========================================
# 1. Windows Packages
# ==========================================
echo "Packaging $DIR_WIN_RUST..."
mkdir -p "$DIR_WIN_RUST"
[ -f "$APK_SRC" ] && cp -f "$APK_SRC" "$DIR_WIN_RUST/arut.apk"
[ -d "$TOOLS_ADB_WIN" ] && cp -rf "$TOOLS_ADB_WIN"/* "$DIR_WIN_RUST/"
[ -f "$ROOT_DIR/relay/rust/target/release/arut.exe" ] && cp -f "$ROOT_DIR/relay/rust/target/release/arut.exe" "$DIR_WIN_RUST/"

cat << 'EOF' > "$DIR_WIN_RUST/arut-run.cmd"
@echo off
if exist "%~dp0arut.exe" (
    "%~dp0arut.exe" run
) else (
    echo [ERROR] arut.exe native binary not found.
)
pause
EOF

cat << 'EOF' > "$DIR_WIN_RUST/arut.cmd"
@echo off
if exist "%~dp0arut.exe" (
    "%~dp0arut.exe" %*
) else (
    echo [ERROR] arut.exe native binary not found.
)
EOF

echo "Packaging $DIR_WIN_JAVA..."
mkdir -p "$DIR_WIN_JAVA"
[ -f "$APK_SRC" ] && cp -f "$APK_SRC" "$DIR_WIN_JAVA/arut.apk"
[ -f "$JAR_SRC" ] && cp -f "$JAR_SRC" "$DIR_WIN_JAVA/arut.jar"
[ -d "$TOOLS_ADB_WIN" ] && cp -rf "$TOOLS_ADB_WIN"/* "$DIR_WIN_JAVA/"

cat << 'EOF' > "$DIR_WIN_JAVA/arut-run.cmd"
@echo off
if exist "%~dp0arut.jar" (
    java -jar "%~dp0arut.jar" run
) else (
    echo [ERROR] arut.jar not found.
)
pause
EOF

cat << 'EOF' > "$DIR_WIN_JAVA/arut.cmd"
@echo off
if exist "%~dp0arut.jar" (
    java -jar "%~dp0arut.jar" %*
) else (
    echo [ERROR] arut.jar not found.
)
EOF

# ==========================================
# 2. Linux Packages
# ==========================================
echo "Packaging $DIR_LINUX_RUST..."
mkdir -p "$DIR_LINUX_RUST"
[ -f "$APK_SRC" ] && cp -f "$APK_SRC" "$DIR_LINUX_RUST/arut.apk"
[ -d "$TOOLS_ADB_LINUX" ] && cp -rf "$TOOLS_ADB_LINUX"/* "$DIR_LINUX_RUST/"
[ -f "$DIR_LINUX_RUST/adb" ] && chmod +x "$DIR_LINUX_RUST/adb"
[ -f "$ROOT_DIR/relay/rust/target/release/arut" ] && cp -f "$ROOT_DIR/relay/rust/target/release/arut" "$DIR_LINUX_RUST/" && chmod +x "$DIR_LINUX_RUST/arut"

cat << 'EOF' > "$DIR_LINUX_RUST/arut-run"
#!/bin/sh
DIR="$(cd "$(dirname "$0")" && pwd)"
export PATH="$DIR:$PATH"
export LD_LIBRARY_PATH="$DIR/lib64:$LD_LIBRARY_PATH"
if [ -f "$DIR/arut" ] && [ -x "$DIR/arut" ]; then
    "$DIR/arut" run
else
    echo "[ERROR] arut native binary not found."
fi
EOF
chmod +x "$DIR_LINUX_RUST/arut-run"

cat << 'EOF' > "$DIR_LINUX_RUST/arut.sh"
#!/bin/sh
DIR="$(cd "$(dirname "$0")" && pwd)"
export PATH="$DIR:$PATH"
export LD_LIBRARY_PATH="$DIR/lib64:$LD_LIBRARY_PATH"
if [ -f "$DIR/arut" ] && [ -x "$DIR/arut" ]; then
    "$DIR/arut" "$@"
else
    echo "[ERROR] arut native binary not found."
fi
EOF
chmod +x "$DIR_LINUX_RUST/arut.sh"

echo "Packaging $DIR_LINUX_JAVA..."
mkdir -p "$DIR_LINUX_JAVA"
[ -f "$APK_SRC" ] && cp -f "$APK_SRC" "$DIR_LINUX_JAVA/arut.apk"
[ -f "$JAR_SRC" ] && cp -f "$JAR_SRC" "$DIR_LINUX_JAVA/arut.jar"
[ -d "$TOOLS_ADB_LINUX" ] && cp -rf "$TOOLS_ADB_LINUX"/* "$DIR_LINUX_JAVA/"
[ -f "$DIR_LINUX_JAVA/adb" ] && chmod +x "$DIR_LINUX_JAVA/adb"

cat << 'EOF' > "$DIR_LINUX_JAVA/arut-run"
#!/bin/sh
DIR="$(cd "$(dirname "$0")" && pwd)"
export PATH="$DIR:$PATH"
export LD_LIBRARY_PATH="$DIR/lib64:$LD_LIBRARY_PATH"
if [ -f "$DIR/arut.jar" ]; then
    exec java -jar "$DIR/arut.jar" run
else
    echo "[ERROR] arut.jar not found."
fi
EOF
chmod +x "$DIR_LINUX_JAVA/arut-run"

cat << 'EOF' > "$DIR_LINUX_JAVA/arut.sh"
#!/bin/sh
DIR="$(cd "$(dirname "$0")" && pwd)"
export PATH="$DIR:$PATH"
export LD_LIBRARY_PATH="$DIR/lib64:$LD_LIBRARY_PATH"
if [ -f "$DIR/arut.jar" ]; then
    exec java -jar "$DIR/arut.jar" "$@"
else
    echo "[ERROR] arut.jar not found."
fi
EOF
chmod +x "$DIR_LINUX_JAVA/arut.sh"

# ==========================================
# 3. macOS Packages
# ==========================================
echo "Packaging $DIR_MACOS_RUST..."
mkdir -p "$DIR_MACOS_RUST"
[ -f "$APK_SRC" ] && cp -f "$APK_SRC" "$DIR_MACOS_RUST/arut.apk"
[ -d "$TOOLS_ADB_MACOS" ] && cp -rf "$TOOLS_ADB_MACOS"/* "$DIR_MACOS_RUST/"
[ -f "$DIR_MACOS_RUST/adb" ] && chmod +x "$DIR_MACOS_RUST/adb"
[ -f "$ROOT_DIR/relay/rust/target/release/arut" ] && cp -f "$ROOT_DIR/relay/rust/target/release/arut" "$DIR_MACOS_RUST/" && chmod +x "$DIR_MACOS_RUST/arut"

cat << 'EOF' > "$DIR_MACOS_RUST/arut-run"
#!/bin/sh
DIR="$(cd "$(dirname "$0")" && pwd)"
export PATH="$DIR:$PATH"
export DYLD_LIBRARY_PATH="$DIR/lib64:$DYLD_LIBRARY_PATH"
if [ -f "$DIR/arut" ] && [ -x "$DIR/arut" ]; then
    "$DIR/arut" run
else
    echo "[ERROR] arut native binary not found."
fi
EOF
chmod +x "$DIR_MACOS_RUST/arut-run"

cat << 'EOF' > "$DIR_MACOS_RUST/arut.sh"
#!/bin/sh
DIR="$(cd "$(dirname "$0")" && pwd)"
export PATH="$DIR:$PATH"
export DYLD_LIBRARY_PATH="$DIR/lib64:$DYLD_LIBRARY_PATH"
if [ -f "$DIR/arut" ] && [ -x "$DIR/arut" ]; then
    "$DIR/arut" "$@"
else
    echo "[ERROR] arut native binary not found."
fi
EOF
chmod +x "$DIR_MACOS_RUST/arut.sh"

echo "Packaging $DIR_MACOS_JAVA..."
mkdir -p "$DIR_MACOS_JAVA"
[ -f "$APK_SRC" ] && cp -f "$APK_SRC" "$DIR_MACOS_JAVA/arut.apk"
[ -f "$JAR_SRC" ] && cp -f "$JAR_SRC" "$DIR_MACOS_JAVA/arut.jar"
[ -d "$TOOLS_ADB_MACOS" ] && cp -rf "$TOOLS_ADB_MACOS"/* "$DIR_MACOS_JAVA/"
[ -f "$DIR_MACOS_JAVA/adb" ] && chmod +x "$DIR_MACOS_JAVA/adb"

cat << 'EOF' > "$DIR_MACOS_JAVA/arut-run"
#!/bin/sh
DIR="$(cd "$(dirname "$0")" && pwd)"
export PATH="$DIR:$PATH"
export DYLD_LIBRARY_PATH="$DIR/lib64:$DYLD_LIBRARY_PATH"
if [ -f "$DIR/arut.jar" ]; then
    exec java -jar "$DIR/arut.jar" run
else
    echo "[ERROR] arut.jar not found."
fi
EOF
chmod +x "$DIR_MACOS_JAVA/arut-run"

cat << 'EOF' > "$DIR_MACOS_JAVA/arut.sh"
#!/bin/sh
DIR="$(cd "$(dirname "$0")" && pwd)"
export PATH="$DIR:$PATH"
export DYLD_LIBRARY_PATH="$DIR/lib64:$DYLD_LIBRARY_PATH"
if [ -f "$DIR/arut.jar" ]; then
    exec java -jar "$DIR/arut.jar" "$@"
else
    echo "[ERROR] arut.jar not found."
fi
EOF
chmod +x "$DIR_MACOS_JAVA/arut.sh"

# ==========================================
# 4. All-Platform Packages
# ==========================================
echo "Packaging $DIR_ALL_RUST..."
mkdir -p "$DIR_ALL_RUST"
[ -f "$APK_SRC" ] && cp -f "$APK_SRC" "$DIR_ALL_RUST/arut.apk"
[ -d "$TOOLS_ADB_WIN" ] && cp -rf "$TOOLS_ADB_WIN"/* "$DIR_ALL_RUST/"
[ -d "$TOOLS_ADB_LINUX" ] && cp -rf "$TOOLS_ADB_LINUX"/* "$DIR_ALL_RUST/"
[ -d "$TOOLS_ADB_MACOS" ] && cp -rf "$TOOLS_ADB_MACOS"/* "$DIR_ALL_RUST/"
[ -f "$DIR_ALL_RUST/adb" ] && chmod +x "$DIR_ALL_RUST/adb"
[ -f "$ROOT_DIR/relay/rust/target/release/arut.exe" ] && cp -f "$ROOT_DIR/relay/rust/target/release/arut.exe" "$DIR_ALL_RUST/"
[ -f "$ROOT_DIR/relay/rust/target/release/arut" ] && cp -f "$ROOT_DIR/relay/rust/target/release/arut" "$DIR_ALL_RUST/" && chmod +x "$DIR_ALL_RUST/arut"

cat << 'EOF' > "$DIR_ALL_RUST/arut-run.cmd"
@echo off
if exist "%~dp0arut.exe" (
    "%~dp0arut.exe" run
) else (
    echo [ERROR] arut.exe native binary not found.
)
pause
EOF

cat << 'EOF' > "$DIR_ALL_RUST/arut.cmd"
@echo off
if exist "%~dp0arut.exe" (
    "%~dp0arut.exe" %*
) else (
    echo [ERROR] arut.exe native binary not found.
)
EOF

cat << 'EOF' > "$DIR_ALL_RUST/arut-run"
#!/bin/sh
DIR="$(cd "$(dirname "$0")" && pwd)"
export PATH="$DIR:$PATH"
export LD_LIBRARY_PATH="$DIR/lib64:$LD_LIBRARY_PATH"
export DYLD_LIBRARY_PATH="$DIR/lib64:$DYLD_LIBRARY_PATH"
if [ -f "$DIR/arut" ] && [ -x "$DIR/arut" ]; then
    "$DIR/arut" run
else
    echo "[ERROR] arut native binary not found."
fi
EOF
chmod +x "$DIR_ALL_RUST/arut-run"

cat << 'EOF' > "$DIR_ALL_RUST/arut.sh"
#!/bin/sh
DIR="$(cd "$(dirname "$0")" && pwd)"
export PATH="$DIR:$PATH"
export LD_LIBRARY_PATH="$DIR/lib64:$LD_LIBRARY_PATH"
export DYLD_LIBRARY_PATH="$DIR/lib64:$DYLD_LIBRARY_PATH"
if [ -f "$DIR/arut" ] && [ -x "$DIR/arut" ]; then
    "$DIR/arut" "$@"
else
    echo "[ERROR] arut native binary not found."
fi
EOF
chmod +x "$DIR_ALL_RUST/arut.sh"

echo "Packaging $DIR_ALL_JAVA..."
mkdir -p "$DIR_ALL_JAVA"
[ -f "$APK_SRC" ] && cp -f "$APK_SRC" "$DIR_ALL_JAVA/arut.apk"
[ -f "$JAR_SRC" ] && cp -f "$JAR_SRC" "$DIR_ALL_JAVA/arut.jar"
[ -d "$TOOLS_ADB_WIN" ] && cp -rf "$TOOLS_ADB_WIN"/* "$DIR_ALL_JAVA/"
[ -d "$TOOLS_ADB_LINUX" ] && cp -rf "$TOOLS_ADB_LINUX"/* "$DIR_ALL_JAVA/"
[ -d "$TOOLS_ADB_MACOS" ] && cp -rf "$TOOLS_ADB_MACOS"/* "$DIR_ALL_JAVA/"
[ -f "$DIR_ALL_JAVA/adb" ] && chmod +x "$DIR_ALL_JAVA/adb"
[ -d "$ROOT_DIR/relay/java/scripts" ] && cp -rf "$ROOT_DIR/relay/java/scripts"/* "$DIR_ALL_JAVA/"

cat << 'EOF' > "$DIR_ALL_JAVA/arut-run.cmd"
@echo off
if exist "%~dp0arut.jar" (
    java -jar "%~dp0arut.jar" run
) else (
    echo [ERROR] arut.jar not found.
)
pause
EOF

cat << 'EOF' > "$DIR_ALL_JAVA/arut.cmd"
@echo off
if exist "%~dp0arut.jar" (
    java -jar "%~dp0arut.jar" %*
) else (
    echo [ERROR] arut.jar not found.
)
EOF

cat << 'EOF' > "$DIR_ALL_JAVA/arut-run"
#!/bin/sh
DIR="$(cd "$(dirname "$0")" && pwd)"
export PATH="$DIR:$PATH"
if [ -f "$DIR/arut.jar" ]; then
    exec java -jar "$DIR/arut.jar" run
else
    echo "[ERROR] arut.jar not found."
fi
EOF
chmod +x "$DIR_ALL_JAVA/arut-run"

cat << 'EOF' > "$DIR_ALL_JAVA/arut.sh"
#!/bin/sh
DIR="$(cd "$(dirname "$0")" && pwd)"
export PATH="$DIR:$PATH"
if [ -f "$DIR/arut.jar" ]; then
    exec java -jar "$DIR/arut.jar" "$@"
else
    echo "[ERROR] arut.jar not found."
fi
EOF
chmod +x "$DIR_ALL_JAVA/arut.sh"

echo ""
echo "========================================================"
echo "  Release Bundles Ready for Zipping / Publishing:"
echo "  - dist/windows/arut-rust-win64-$VERSION/"
echo "  - dist/windows/arut-java-win64-$VERSION/"
echo "  - dist/linux/arut-rust-linux64-$VERSION/"
echo "  - dist/linux/arut-java-linux64-$VERSION/"
echo "  - dist/macos/arut-rust-macos64-$VERSION/"
echo "  - dist/macos/arut-java-macos64-$VERSION/"
echo "  - dist/all-platform/arut-rust-all-$VERSION/"
echo "  - dist/all-platform/arut-java-all-$VERSION/"
echo "========================================================"
