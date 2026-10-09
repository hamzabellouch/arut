@echo off
setlocal enabledelayedexpansion

set "ROOT_DIR=%~dp0"
cd /d "%ROOT_DIR%"

set "VERSION=v0.0.1-beta"

echo ========================================================
echo   Building ARUT Multi-Platform Release Packages (%VERSION%)
echo ========================================================

:: 1. Build Android Client APK inside application/
echo [1/3] Building Android APK inside application/...
cd /d "%ROOT_DIR%application"
call gradlew.bat assembleRelease
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Android build failed.
    exit /b %ERRORLEVEL%
)
cd /d "%ROOT_DIR%"

:: 2. Build Java Relay Server inside relay/java/
echo [2/3] Building Java Relay Server inside relay/java/...
cd /d "%ROOT_DIR%relay\java"
call "%ROOT_DIR%application\gradlew.bat" assembleRelease
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Java relay build failed.
    exit /b %ERRORLEVEL%
)
cd /d "%ROOT_DIR%"

:: 3. Build Rust Relay Server inside relay/rust/ (if Cargo is installed)
echo [3/3] Checking Rust toolchain...
if exist "%USERPROFILE%\.cargo\bin" set "PATH=%USERPROFILE%\.cargo\bin;%PATH%"
where cargo >nul 2>&1
if %ERRORLEVEL% equ 0 (
    echo Building Rust Relay Server (native) inside relay/rust/...
    cd /d "%ROOT_DIR%relay\rust"
    cargo build --release

    echo Checking Rust Linux target (x86_64-unknown-linux-musl)...
    where rustup >nul 2>&1
    if !ERRORLEVEL! equ 0 (
        rustup target list --installed 2>nul | findstr /i "x86_64-unknown-linux-musl" >nul
        if !ERRORLEVEL! neq 0 (
            echo Adding x86_64-unknown-linux-musl target via rustup...
            rustup target add x86_64-unknown-linux-musl >nul 2>&1
        )
        echo Building Rust Relay Server (Linux static binary)...
        set "RUSTFLAGS=-C linker=rust-lld"
        cargo build --release --target x86_64-unknown-linux-musl
    )
    cd /d "%ROOT_DIR%"
) else (
    echo [INFO] Cargo not found in PATH. Skipping Rust native compilation.
)

:: 4. Clean and assemble release packages inside dist/
echo.
echo Packaging release bundles into dist/...

set "APK_SRC=%ROOT_DIR%application\app\build\outputs\apk\release\arut-release-unsigned.apk"
if not exist "%APK_SRC%" set "APK_SRC=%ROOT_DIR%application\app\build\outputs\apk\release\arut-release.apk"

set "JAR_SRC=%ROOT_DIR%relay\java\build\libs\arut.jar"
set "TOOLS_ADB_WIN=%ROOT_DIR%tools\adb\windows"
set "TOOLS_ADB_LINUX=%ROOT_DIR%tools\adb\linux"
set "TOOLS_ADB_MACOS=%ROOT_DIR%tools\adb\macos"
set "TEMPLATES_SCRIPTS=%ROOT_DIR%tools\templates\scripts"

set "RUST_BIN_WIN=%ROOT_DIR%relay\rust\target\release\arut.exe"
set "RUST_BIN_LINUX=%ROOT_DIR%relay\rust\target\x86_64-unknown-linux-musl\release\arut"
if not exist "%RUST_BIN_LINUX%" set "RUST_BIN_LINUX=%ROOT_DIR%relay\rust\target\release\arut"

set "DIR_WIN_RUST=%ROOT_DIR%dist\windows\arut-rust-win64-%VERSION%"
set "DIR_WIN_JAVA=%ROOT_DIR%dist\windows\arut-java-win64-%VERSION%"
set "DIR_LINUX_RUST=%ROOT_DIR%dist\linux\arut-rust-linux64-%VERSION%"
set "DIR_LINUX_JAVA=%ROOT_DIR%dist\linux\arut-java-linux64-%VERSION%"
set "DIR_MACOS_RUST=%ROOT_DIR%dist\macos\arut-rust-macos64-%VERSION%"
set "DIR_MACOS_JAVA=%ROOT_DIR%dist\macos\arut-java-macos64-%VERSION%"
set "DIR_ALL_RUST=%ROOT_DIR%dist\all-platform\arut-rust-all-%VERSION%"
set "DIR_ALL_JAVA=%ROOT_DIR%dist\all-platform\arut-java-all-%VERSION%"

:: Clean target release directories
if exist "%ROOT_DIR%dist" rd /s /q "%ROOT_DIR%dist"

:: ==========================================
:: 1. Windows Packages
:: ==========================================
echo Packaging %DIR_WIN_RUST%...
mkdir "%DIR_WIN_RUST%"
if exist "%APK_SRC%" copy /y "%APK_SRC%" "%DIR_WIN_RUST%\arut.apk" >nul
if exist "%TOOLS_ADB_WIN%" xcopy /y /q /s "%TOOLS_ADB_WIN%\*" "%DIR_WIN_RUST%\" >nul
if exist "%RUST_BIN_WIN%" copy /y "%RUST_BIN_WIN%" "%DIR_WIN_RUST%\" >nul
if exist "%TEMPLATES_SCRIPTS%\windows\rust" copy /y "%TEMPLATES_SCRIPTS%\windows\rust\*" "%DIR_WIN_RUST%\" >nul

echo Packaging %DIR_WIN_JAVA%...
mkdir "%DIR_WIN_JAVA%"
if exist "%APK_SRC%" copy /y "%APK_SRC%" "%DIR_WIN_JAVA%\arut.apk" >nul
if exist "%JAR_SRC%" copy /y "%JAR_SRC%" "%DIR_WIN_JAVA%\arut.jar" >nul
if exist "%TOOLS_ADB_WIN%" xcopy /y /q /s "%TOOLS_ADB_WIN%\*" "%DIR_WIN_JAVA%\" >nul
if exist "%TEMPLATES_SCRIPTS%\windows\java" copy /y "%TEMPLATES_SCRIPTS%\windows\java\*" "%DIR_WIN_JAVA%\" >nul

:: ==========================================
:: 2. Linux Packages
:: ==========================================
echo Packaging %DIR_LINUX_RUST%...
mkdir "%DIR_LINUX_RUST%"
if exist "%APK_SRC%" copy /y "%APK_SRC%" "%DIR_LINUX_RUST%\arut.apk" >nul
if exist "%TOOLS_ADB_LINUX%" xcopy /y /q /s "%TOOLS_ADB_LINUX%\*" "%DIR_LINUX_RUST%\" >nul
if exist "%RUST_BIN_LINUX%" copy /y "%RUST_BIN_LINUX%" "%DIR_LINUX_RUST%\arut" >nul
if exist "%TEMPLATES_SCRIPTS%\linux\rust" copy /y "%TEMPLATES_SCRIPTS%\linux\rust\*" "%DIR_LINUX_RUST%\" >nul

echo Packaging %DIR_LINUX_JAVA%...
mkdir "%DIR_LINUX_JAVA%"
if exist "%APK_SRC%" copy /y "%APK_SRC%" "%DIR_LINUX_JAVA%\arut.apk" >nul
if exist "%JAR_SRC%" copy /y "%JAR_SRC%" "%DIR_LINUX_JAVA%\arut.jar" >nul
if exist "%TOOLS_ADB_LINUX%" xcopy /y /q /s "%TOOLS_ADB_LINUX%\*" "%DIR_LINUX_JAVA%\" >nul
if exist "%TEMPLATES_SCRIPTS%\linux\java" copy /y "%TEMPLATES_SCRIPTS%\linux\java\*" "%DIR_LINUX_JAVA%\" >nul

:: ==========================================
:: 3. macOS Packages
:: ==========================================
echo Packaging %DIR_MACOS_RUST%...
mkdir "%DIR_MACOS_RUST%"
if exist "%APK_SRC%" copy /y "%APK_SRC%" "%DIR_MACOS_RUST%\arut.apk" >nul
if exist "%TOOLS_ADB_MACOS%" xcopy /y /q /s "%TOOLS_ADB_MACOS%\*" "%DIR_MACOS_RUST%\" >nul
if exist "%ROOT_DIR%relay\rust\target\release\arut" copy /y "%ROOT_DIR%relay\rust\target\release\arut" "%DIR_MACOS_RUST%\" >nul
if exist "%TEMPLATES_SCRIPTS%\macos\rust" copy /y "%TEMPLATES_SCRIPTS%\macos\rust\*" "%DIR_MACOS_RUST%\" >nul

echo Packaging %DIR_MACOS_JAVA%...
mkdir "%DIR_MACOS_JAVA%"
if exist "%APK_SRC%" copy /y "%APK_SRC%" "%DIR_MACOS_JAVA%\arut.apk" >nul
if exist "%JAR_SRC%" copy /y "%JAR_SRC%" "%DIR_MACOS_JAVA%\arut.jar" >nul
if exist "%TOOLS_ADB_MACOS%" xcopy /y /q /s "%TOOLS_ADB_MACOS%\*" "%DIR_MACOS_JAVA%\" >nul
if exist "%TEMPLATES_SCRIPTS%\macos\java" copy /y "%TEMPLATES_SCRIPTS%\macos\java\*" "%DIR_MACOS_JAVA%\" >nul

:: ==========================================
:: 4. All-Platform Packages
:: ==========================================
echo Packaging %DIR_ALL_RUST%...
mkdir "%DIR_ALL_RUST%"
if exist "%APK_SRC%" copy /y "%APK_SRC%" "%DIR_ALL_RUST%\arut.apk" >nul
if exist "%TOOLS_ADB_WIN%" xcopy /y /q /s "%TOOLS_ADB_WIN%\*" "%DIR_ALL_RUST%\" >nul
if exist "%TOOLS_ADB_LINUX%" xcopy /y /q /s "%TOOLS_ADB_LINUX%\*" "%DIR_ALL_RUST%\" >nul
if exist "%TOOLS_ADB_MACOS%" xcopy /y /q /s "%TOOLS_ADB_MACOS%\*" "%DIR_ALL_RUST%\" >nul
if exist "%RUST_BIN_WIN%" copy /y "%RUST_BIN_WIN%" "%DIR_ALL_RUST%\" >nul
if exist "%RUST_BIN_LINUX%" copy /y "%RUST_BIN_LINUX%" "%DIR_ALL_RUST%\arut" >nul
if exist "%TEMPLATES_SCRIPTS%\all-platform\rust" copy /y "%TEMPLATES_SCRIPTS%\all-platform\rust\*" "%DIR_ALL_RUST%\" >nul

echo Packaging %DIR_ALL_JAVA%...
mkdir "%DIR_ALL_JAVA%"
if exist "%APK_SRC%" copy /y "%APK_SRC%" "%DIR_ALL_JAVA%\arut.apk" >nul
if exist "%JAR_SRC%" copy /y "%JAR_SRC%" "%DIR_ALL_JAVA%\arut.jar" >nul
if exist "%TOOLS_ADB_WIN%" xcopy /y /q /s "%TOOLS_ADB_WIN%\*" "%DIR_ALL_JAVA%\" >nul
if exist "%TOOLS_ADB_LINUX%" xcopy /y /q /s "%TOOLS_ADB_LINUX%\*" "%DIR_ALL_JAVA%\" >nul
if exist "%TOOLS_ADB_MACOS%" xcopy /y /q /s "%TOOLS_ADB_MACOS%\*" "%DIR_ALL_JAVA%\" >nul
if exist "%TEMPLATES_SCRIPTS%\all-platform\java" copy /y "%TEMPLATES_SCRIPTS%\all-platform\java\*" "%DIR_ALL_JAVA%\" >nul

:: ==========================================
:: 5. Create Distribution Zip Archives
:: ==========================================
echo.
echo Compressing distribution packages into .zip archives...
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
    "Add-Type -AssemblyName System.IO.Compression.FileSystem; ^
    @('%DIR_WIN_RUST%', '%DIR_WIN_JAVA%', '%DIR_LINUX_RUST%', '%DIR_LINUX_JAVA%', '%DIR_MACOS_RUST%', '%DIR_MACOS_JAVA%', '%DIR_ALL_RUST%', '%DIR_ALL_JAVA%') | ForEach-Object { ^
        if (Test-Path $_) { ^
            $zipPath = $_ + '.zip'; ^
            if (Test-Path $zipPath) { Remove-Item -Force $zipPath }; ^
            [System.IO.Compression.ZipFile]::CreateFromDirectory($_, $zipPath, [System.IO.Compression.CompressionLevel]::Optimal, $true); ^
            Write-Host ('  [OK] Created ' + $zipPath) ^
        } ^
    }"

echo.
echo ========================================================
echo   Release Bundles Ready in dist/:
echo   - dist\windows\arut-rust-win64-%VERSION%.zip
echo   - dist\windows\arut-java-win64-%VERSION%.zip
echo   - dist\linux\arut-rust-linux64-%VERSION%.zip
echo   - dist\linux\arut-java-linux64-%VERSION%.zip
echo   - dist\macos\arut-rust-macos64-%VERSION%.zip
echo   - dist\macos\arut-java-macos64-%VERSION%.zip
echo   - dist\all-platform\arut-rust-all-%VERSION%.zip
echo   - dist\all-platform\arut-java-all-%VERSION%.zip
echo ========================================================
