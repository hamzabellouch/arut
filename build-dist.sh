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
TEMPLATES_SCRIPTS="$ROOT_DIR/tools/templates/scripts"

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
[ -d "$TEMPLATES_SCRIPTS/windows/rust" ] && cp -rf "$TEMPLATES_SCRIPTS/windows/rust"/* "$DIR_WIN_RUST/"

echo "Packaging $DIR_WIN_JAVA..."
mkdir -p "$DIR_WIN_JAVA"
[ -f "$APK_SRC" ] && cp -f "$APK_SRC" "$DIR_WIN_JAVA/arut.apk"
[ -f "$JAR_SRC" ] && cp -f "$JAR_SRC" "$DIR_WIN_JAVA/arut.jar"
[ -d "$TOOLS_ADB_WIN" ] && cp -rf "$TOOLS_ADB_WIN"/* "$DIR_WIN_JAVA/"
[ -d "$TEMPLATES_SCRIPTS/windows/java" ] && cp -rf "$TEMPLATES_SCRIPTS/windows/java"/* "$DIR_WIN_JAVA/"

# ==========================================
# 2. Linux Packages
# ==========================================
echo "Packaging $DIR_LINUX_RUST..."
mkdir -p "$DIR_LINUX_RUST"
[ -f "$APK_SRC" ] && cp -f "$APK_SRC" "$DIR_LINUX_RUST/arut.apk"
[ -d "$TOOLS_ADB_LINUX" ] && cp -rf "$TOOLS_ADB_LINUX"/* "$DIR_LINUX_RUST/"
[ -f "$DIR_LINUX_RUST/adb" ] && chmod +x "$DIR_LINUX_RUST/adb"
[ -f "$ROOT_DIR/relay/rust/target/release/arut" ] && cp -f "$ROOT_DIR/relay/rust/target/release/arut" "$DIR_LINUX_RUST/" && chmod +x "$DIR_LINUX_RUST/arut"
[ -d "$TEMPLATES_SCRIPTS/linux/rust" ] && cp -rf "$TEMPLATES_SCRIPTS/linux/rust"/* "$DIR_LINUX_RUST/"
[ -f "$DIR_LINUX_RUST/arut-run" ] && chmod +x "$DIR_LINUX_RUST/arut-run"
[ -f "$DIR_LINUX_RUST/arut.sh" ] && chmod +x "$DIR_LINUX_RUST/arut.sh"

echo "Packaging $DIR_LINUX_JAVA..."
mkdir -p "$DIR_LINUX_JAVA"
[ -f "$APK_SRC" ] && cp -f "$APK_SRC" "$DIR_LINUX_JAVA/arut.apk"
[ -f "$JAR_SRC" ] && cp -f "$JAR_SRC" "$DIR_LINUX_JAVA/arut.jar"
[ -d "$TOOLS_ADB_LINUX" ] && cp -rf "$TOOLS_ADB_LINUX"/* "$DIR_LINUX_JAVA/"
[ -f "$DIR_LINUX_JAVA/adb" ] && chmod +x "$DIR_LINUX_JAVA/adb"
[ -d "$TEMPLATES_SCRIPTS/linux/java" ] && cp -rf "$TEMPLATES_SCRIPTS/linux/java"/* "$DIR_LINUX_JAVA/"
[ -f "$DIR_LINUX_JAVA/arut-run" ] && chmod +x "$DIR_LINUX_JAVA/arut-run"
[ -f "$DIR_LINUX_JAVA/arut.sh" ] && chmod +x "$DIR_LINUX_JAVA/arut.sh"

# ==========================================
# 3. macOS Packages
# ==========================================
echo "Packaging $DIR_MACOS_RUST..."
mkdir -p "$DIR_MACOS_RUST"
[ -f "$APK_SRC" ] && cp -f "$APK_SRC" "$DIR_MACOS_RUST/arut.apk"
[ -d "$TOOLS_ADB_MACOS" ] && cp -rf "$TOOLS_ADB_MACOS"/* "$DIR_MACOS_RUST/"
[ -f "$DIR_MACOS_RUST/adb" ] && chmod +x "$DIR_MACOS_RUST/adb"
[ -f "$ROOT_DIR/relay/rust/target/release/arut" ] && cp -f "$ROOT_DIR/relay/rust/target/release/arut" "$DIR_MACOS_RUST/" && chmod +x "$DIR_MACOS_RUST/arut"
[ -d "$TEMPLATES_SCRIPTS/macos/rust" ] && cp -rf "$TEMPLATES_SCRIPTS/macos/rust"/* "$DIR_MACOS_RUST/"
[ -f "$DIR_MACOS_RUST/arut-run" ] && chmod +x "$DIR_MACOS_RUST/arut-run"
[ -f "$DIR_MACOS_RUST/arut.sh" ] && chmod +x "$DIR_MACOS_RUST/arut.sh"

echo "Packaging $DIR_MACOS_JAVA..."
mkdir -p "$DIR_MACOS_JAVA"
[ -f "$APK_SRC" ] && cp -f "$APK_SRC" "$DIR_MACOS_JAVA/arut.apk"
[ -f "$JAR_SRC" ] && cp -f "$JAR_SRC" "$DIR_MACOS_JAVA/arut.jar"
[ -d "$TOOLS_ADB_MACOS" ] && cp -rf "$TOOLS_ADB_MACOS"/* "$DIR_MACOS_JAVA/"
[ -f "$DIR_MACOS_JAVA/adb" ] && chmod +x "$DIR_MACOS_JAVA/adb"
[ -d "$TEMPLATES_SCRIPTS/macos/java" ] && cp -rf "$TEMPLATES_SCRIPTS/macos/java"/* "$DIR_MACOS_JAVA/"
[ -f "$DIR_MACOS_JAVA/arut-run" ] && chmod +x "$DIR_MACOS_JAVA/arut-run"
[ -f "$DIR_MACOS_JAVA/arut.sh" ] && chmod +x "$DIR_MACOS_JAVA/arut.sh"

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
[ -d "$TEMPLATES_SCRIPTS/all-platform/rust" ] && cp -rf "$TEMPLATES_SCRIPTS/all-platform/rust"/* "$DIR_ALL_RUST/"
[ -f "$DIR_ALL_RUST/arut-run" ] && chmod +x "$DIR_ALL_RUST/arut-run"
[ -f "$DIR_ALL_RUST/arut.sh" ] && chmod +x "$DIR_ALL_RUST/arut.sh"

echo "Packaging $DIR_ALL_JAVA..."
mkdir -p "$DIR_ALL_JAVA"
[ -f "$APK_SRC" ] && cp -f "$APK_SRC" "$DIR_ALL_JAVA/arut.apk"
[ -f "$JAR_SRC" ] && cp -f "$JAR_SRC" "$DIR_ALL_JAVA/arut.jar"
[ -d "$TOOLS_ADB_WIN" ] && cp -rf "$TOOLS_ADB_WIN"/* "$DIR_ALL_JAVA/"
[ -d "$TOOLS_ADB_LINUX" ] && cp -rf "$TOOLS_ADB_LINUX"/* "$DIR_ALL_JAVA/"
[ -d "$TOOLS_ADB_MACOS" ] && cp -rf "$TOOLS_ADB_MACOS"/* "$DIR_ALL_JAVA/"
[ -f "$DIR_ALL_JAVA/adb" ] && chmod +x "$DIR_ALL_JAVA/adb"
[ -d "$TEMPLATES_SCRIPTS/all-platform/java" ] && cp -rf "$TEMPLATES_SCRIPTS/all-platform/java"/* "$DIR_ALL_JAVA/"
[ -f "$DIR_ALL_JAVA/arut-run" ] && chmod +x "$DIR_ALL_JAVA/arut-run"
[ -f "$DIR_ALL_JAVA/arut.sh" ] && chmod +x "$DIR_ALL_JAVA/arut.sh"
[ -f "$DIR_ALL_JAVA/arut" ] && chmod +x "$DIR_ALL_JAVA/arut"

# ==========================================
# 5. Create Distribution Zip Archives
# ==========================================
echo ""
echo "Compressing distribution packages into .zip archives..."
if command -v zip >/dev/null 2>&1; then
    cd "$ROOT_DIR/dist/windows" && zip -r "arut-rust-win64-$VERSION.zip" "arut-rust-win64-$VERSION"
    cd "$ROOT_DIR/dist/windows" && zip -r "arut-java-win64-$VERSION.zip" "arut-java-win64-$VERSION"
    cd "$ROOT_DIR/dist/linux" && zip -r "arut-rust-linux64-$VERSION.zip" "arut-rust-linux64-$VERSION"
    cd "$ROOT_DIR/dist/linux" && zip -r "arut-java-linux64-$VERSION.zip" "arut-java-linux64-$VERSION"
    cd "$ROOT_DIR/dist/macos" && zip -r "arut-rust-macos64-$VERSION.zip" "arut-rust-macos64-$VERSION"
    cd "$ROOT_DIR/dist/macos" && zip -r "arut-java-macos64-$VERSION.zip" "arut-java-macos64-$VERSION"
    cd "$ROOT_DIR/dist/all-platform" && zip -r "arut-rust-all-$VERSION.zip" "arut-rust-all-$VERSION"
    cd "$ROOT_DIR/dist/all-platform" && zip -r "arut-java-all-$VERSION.zip" "arut-java-all-$VERSION"
    cd "$ROOT_DIR"
fi

echo ""
echo "========================================================"
echo "  Release Bundles Ready in dist/:"
echo "  - dist/windows/arut-rust-win64-$VERSION.zip"
echo "  - dist/windows/arut-java-win64-$VERSION.zip"
echo "  - dist/linux/arut-rust-linux64-$VERSION.zip"
echo "  - dist/linux/arut-java-linux64-$VERSION.zip"
echo "  - dist/macos/arut-rust-macos64-$VERSION.zip"
echo "  - dist/macos/arut-java-macos64-$VERSION.zip"
echo "  - dist/all-platform/arut-rust-all-$VERSION.zip"
echo "  - dist/all-platform/arut-java-all-$VERSION.zip"
echo "========================================================"
