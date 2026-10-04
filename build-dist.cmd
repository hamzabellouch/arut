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
    echo Building Rust Relay Server inside relay/rust/...
    cd /d "%ROOT_DIR%relay\rust"
    cargo build --release
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
if exist "%ROOT_DIR%relay\rust\target\release\arut.exe" copy /y "%ROOT_DIR%relay\rust\target\release\arut.exe" "%DIR_WIN_RUST%\" >nul

(
    echo @echo off
    echo if exist "%%~dp0arut.exe" ^(
    echo     "%%~dp0arut.exe" run
    echo ^) else ^(
    echo     echo [ERROR] arut.exe native binary not found.
    echo ^)
    echo pause
) > "%DIR_WIN_RUST%\arut-run.cmd"

(
    echo @echo off
    echo if exist "%%~dp0arut.exe" ^(
    echo     "%%~dp0arut.exe" %%*
    echo ^) else ^(
    echo     echo [ERROR] arut.exe native binary not found.
    echo ^)
) > "%DIR_WIN_RUST%\arut.cmd"

echo Packaging %DIR_WIN_JAVA%...
mkdir "%DIR_WIN_JAVA%"
if exist "%APK_SRC%" copy /y "%APK_SRC%" "%DIR_WIN_JAVA%\arut.apk" >nul
if exist "%JAR_SRC%" copy /y "%JAR_SRC%" "%DIR_WIN_JAVA%\arut.jar" >nul
if exist "%TOOLS_ADB_WIN%" xcopy /y /q /s "%TOOLS_ADB_WIN%\*" "%DIR_WIN_JAVA%\" >nul

(
    echo @echo off
    echo if exist "%%~dp0arut.jar" ^(
    echo     java -jar "%%~dp0arut.jar" run
    echo ^) else ^(
    echo     echo [ERROR] arut.jar not found.
    echo ^)
    echo pause
) > "%DIR_WIN_JAVA%\arut-run.cmd"

(
    echo @echo off
    echo if exist "%%~dp0arut.jar" ^(
    echo     java -jar "%%~dp0arut.jar" %%*
    echo ^) else ^(
    echo     echo [ERROR] arut.jar not found.
    echo ^)
) > "%DIR_WIN_JAVA%\arut.cmd"

:: ==========================================
:: 2. Linux Packages
:: ==========================================
echo Packaging %DIR_LINUX_RUST%...
mkdir "%DIR_LINUX_RUST%"
if exist "%APK_SRC%" copy /y "%APK_SRC%" "%DIR_LINUX_RUST%\arut.apk" >nul
if exist "%TOOLS_ADB_LINUX%" xcopy /y /q /s "%TOOLS_ADB_LINUX%\*" "%DIR_LINUX_RUST%\" >nul
if exist "%ROOT_DIR%relay\rust\target\release\arut" copy /y "%ROOT_DIR%relay\rust\target\release\arut" "%DIR_LINUX_RUST%\" >nul

(
    echo #!/bin/sh
    echo DIR="$^(cd "$^(dirname "$0"^)" ^&^& pwd^)"
    echo export PATH="$DIR:$PATH"
    echo export LD_LIBRARY_PATH="$DIR/lib64:$LD_LIBRARY_PATH"
    echo if [ -f "$DIR/arut" ] ^&^& [ -x "$DIR/arut" ]; then
    echo     "$DIR/arut" run
    echo else
    echo     echo "[ERROR] arut native binary not found."
    echo fi
) > "%DIR_LINUX_RUST%\arut-run"

(
    echo #!/bin/sh
    echo DIR="$^(cd "$^(dirname "$0"^)" ^&^& pwd^)"
    echo export PATH="$DIR:$PATH"
    echo export LD_LIBRARY_PATH="$DIR/lib64:$LD_LIBRARY_PATH"
    echo if [ -f "$DIR/arut" ] ^&^& [ -x "$DIR/arut" ]; then
    echo     "$DIR/arut" "$@"
    echo else
    echo     echo "[ERROR] arut native binary not found."
    echo fi
) > "%DIR_LINUX_RUST%\arut.sh"

echo Packaging %DIR_LINUX_JAVA%...
mkdir "%DIR_LINUX_JAVA%"
if exist "%APK_SRC%" copy /y "%APK_SRC%" "%DIR_LINUX_JAVA%\arut.apk" >nul
if exist "%JAR_SRC%" copy /y "%JAR_SRC%" "%DIR_LINUX_JAVA%\arut.jar" >nul
if exist "%TOOLS_ADB_LINUX%" xcopy /y /q /s "%TOOLS_ADB_LINUX%\*" "%DIR_LINUX_JAVA%\" >nul

(
    echo #!/bin/sh
    echo DIR="$^(cd "$^(dirname "$0"^)" ^&^& pwd^)"
    echo export PATH="$DIR:$PATH"
    echo export LD_LIBRARY_PATH="$DIR/lib64:$LD_LIBRARY_PATH"
    echo if [ -f "$DIR/arut.jar" ]; then
    echo     exec java -jar "$DIR/arut.jar" run
    echo else
    echo     echo "[ERROR] arut.jar not found."
    echo fi
) > "%DIR_LINUX_JAVA%\arut-run"

(
    echo #!/bin/sh
    echo DIR="$^(cd "$^(dirname "$0"^)" ^&^& pwd^)"
    echo export PATH="$DIR:$PATH"
    echo export LD_LIBRARY_PATH="$DIR/lib64:$LD_LIBRARY_PATH"
    echo if [ -f "$DIR/arut.jar" ]; then
    echo     exec java -jar "$DIR/arut.jar" "$@"
    echo else
    echo     echo "[ERROR] arut.jar not found."
    echo fi
) > "%DIR_LINUX_JAVA%\arut.sh"

:: ==========================================
:: 3. macOS Packages
:: ==========================================
echo Packaging %DIR_MACOS_RUST%...
mkdir "%DIR_MACOS_RUST%"
if exist "%APK_SRC%" copy /y "%APK_SRC%" "%DIR_MACOS_RUST%\arut.apk" >nul
if exist "%TOOLS_ADB_MACOS%" xcopy /y /q /s "%TOOLS_ADB_MACOS%\*" "%DIR_MACOS_RUST%\" >nul
if exist "%ROOT_DIR%relay\rust\target\release\arut" copy /y "%ROOT_DIR%relay\rust\target\release\arut" "%DIR_MACOS_RUST%\" >nul

(
    echo #!/bin/sh
    echo DIR="$^(cd "$^(dirname "$0"^)" ^&^& pwd^)"
    echo export PATH="$DIR:$PATH"
    echo export DYLD_LIBRARY_PATH="$DIR/lib64:$DYLD_LIBRARY_PATH"
    echo if [ -f "$DIR/arut" ] ^&^& [ -x "$DIR/arut" ]; then
    echo     "$DIR/arut" run
    echo else
    echo     echo "[ERROR] arut native binary not found."
    echo fi
) > "%DIR_MACOS_RUST%\arut-run"

(
    echo #!/bin/sh
    echo DIR="$^(cd "$^(dirname "$0"^)" ^&^& pwd^)"
    echo export PATH="$DIR:$PATH"
    echo export DYLD_LIBRARY_PATH="$DIR/lib64:$DYLD_LIBRARY_PATH"
    echo if [ -f "$DIR/arut" ] ^&^& [ -x "$DIR/arut" ]; then
    echo     "$DIR/arut" "$@"
    echo else
    echo     echo "[ERROR] arut native binary not found."
    echo fi
) > "%DIR_MACOS_RUST%\arut.sh"

echo Packaging %DIR_MACOS_JAVA%...
mkdir "%DIR_MACOS_JAVA%"
if exist "%APK_SRC%" copy /y "%APK_SRC%" "%DIR_MACOS_JAVA%\arut.apk" >nul
if exist "%JAR_SRC%" copy /y "%JAR_SRC%" "%DIR_MACOS_JAVA%\arut.jar" >nul
if exist "%TOOLS_ADB_MACOS%" xcopy /y /q /s "%TOOLS_ADB_MACOS%\*" "%DIR_MACOS_JAVA%\" >nul

(
    echo #!/bin/sh
    echo DIR="$^(cd "$^(dirname "$0"^)" ^&^& pwd^)"
    echo export PATH="$DIR:$PATH"
    echo export DYLD_LIBRARY_PATH="$DIR/lib64:$DYLD_LIBRARY_PATH"
    echo if [ -f "$DIR/arut.jar" ]; then
    echo     exec java -jar "$DIR/arut.jar" run
    echo else
    echo     echo "[ERROR] arut.jar not found."
    echo fi
) > "%DIR_MACOS_JAVA%\arut-run"

(
    echo #!/bin/sh
    echo DIR="$^(cd "$^(dirname "$0"^)" ^&^& pwd^)"
    echo export PATH="$DIR:$PATH"
    echo export DYLD_LIBRARY_PATH="$DIR/lib64:$DYLD_LIBRARY_PATH"
    echo if [ -f "$DIR/arut.jar" ]; then
    echo     exec java -jar "$DIR/arut.jar" "$@"
    echo else
    echo     echo "[ERROR] arut.jar not found."
    echo fi
) > "%DIR_MACOS_JAVA%\arut.sh"

:: ==========================================
:: 4. All-Platform Packages
:: ==========================================
echo Packaging %DIR_ALL_RUST%...
mkdir "%DIR_ALL_RUST%"
if exist "%APK_SRC%" copy /y "%APK_SRC%" "%DIR_ALL_RUST%\arut.apk" >nul
if exist "%TOOLS_ADB_WIN%" xcopy /y /q /s "%TOOLS_ADB_WIN%\*" "%DIR_ALL_RUST%\" >nul
if exist "%TOOLS_ADB_LINUX%" xcopy /y /q /s "%TOOLS_ADB_LINUX%\*" "%DIR_ALL_RUST%\" >nul
if exist "%TOOLS_ADB_MACOS%" xcopy /y /q /s "%TOOLS_ADB_MACOS%\*" "%DIR_ALL_RUST%\" >nul
if exist "%ROOT_DIR%relay\rust\target\release\arut.exe" copy /y "%ROOT_DIR%relay\rust\target\release\arut.exe" "%DIR_ALL_RUST%\" >nul
if exist "%ROOT_DIR%relay\rust\target\release\arut" copy /y "%ROOT_DIR%relay\rust\target\release\arut" "%DIR_ALL_RUST%\" >nul

(
    echo @echo off
    echo if exist "%%~dp0arut.exe" ^(
    echo     "%%~dp0arut.exe" run
    echo ^) else ^(
    echo     echo [ERROR] arut.exe native binary not found.
    echo ^)
    echo pause
) > "%DIR_ALL_RUST%\arut-run.cmd"

(
    echo @echo off
    echo if exist "%%~dp0arut.exe" ^(
    echo     "%%~dp0arut.exe" %%*
    echo ^) else ^(
    echo     echo [ERROR] arut.exe native binary not found.
    echo ^)
) > "%DIR_ALL_RUST%\arut.cmd"

(
    echo #!/bin/sh
    echo DIR="$^(cd "$^(dirname "$0"^)" ^&^& pwd^)"
    echo export PATH="$DIR:$PATH"
    echo export LD_LIBRARY_PATH="$DIR/lib64:$LD_LIBRARY_PATH"
    echo export DYLD_LIBRARY_PATH="$DIR/lib64:$DYLD_LIBRARY_PATH"
    echo if [ -f "$DIR/arut" ] ^&^& [ -x "$DIR/arut" ]; then
    echo     "$DIR/arut" run
    echo else
    echo     echo "[ERROR] arut native binary not found."
    echo fi
) > "%DIR_ALL_RUST%\arut-run"

(
    echo #!/bin/sh
    echo DIR="$^(cd "$^(dirname "$0"^)" ^&^& pwd^)"
    echo export PATH="$DIR:$PATH"
    echo export LD_LIBRARY_PATH="$DIR/lib64:$LD_LIBRARY_PATH"
    echo export DYLD_LIBRARY_PATH="$DIR/lib64:$DYLD_LIBRARY_PATH"
    echo if [ -f "$DIR/arut" ] ^&^& [ -x "$DIR/arut" ]; then
    echo     "$DIR/arut" "$@"
    echo else
    echo     echo "[ERROR] arut native binary not found."
    echo fi
) > "%DIR_ALL_RUST%\arut.sh"

echo Packaging %DIR_ALL_JAVA%...
mkdir "%DIR_ALL_JAVA%"
if exist "%APK_SRC%" copy /y "%APK_SRC%" "%DIR_ALL_JAVA%\arut.apk" >nul
if exist "%JAR_SRC%" copy /y "%JAR_SRC%" "%DIR_ALL_JAVA%\arut.jar" >nul
if exist "%TOOLS_ADB_WIN%" xcopy /y /q /s "%TOOLS_ADB_WIN%\*" "%DIR_ALL_JAVA%\" >nul
if exist "%TOOLS_ADB_LINUX%" xcopy /y /q /s "%TOOLS_ADB_LINUX%\*" "%DIR_ALL_JAVA%\" >nul
if exist "%TOOLS_ADB_MACOS%" xcopy /y /q /s "%TOOLS_ADB_MACOS%\*" "%DIR_ALL_JAVA%\" >nul
if exist "%ROOT_DIR%relay\java\scripts" xcopy /y /q "%ROOT_DIR%relay\java\scripts\*" "%DIR_ALL_JAVA%\" >nul

(
    echo @echo off
    echo if exist "%%~dp0arut.jar" ^(
    echo     java -jar "%%~dp0arut.jar" run
    echo ^) else ^(
    echo     echo [ERROR] arut.jar not found.
    echo ^)
    echo pause
) > "%DIR_ALL_JAVA%\arut-run.cmd"

(
    echo @echo off
    echo if exist "%%~dp0arut.jar" ^(
    echo     java -jar "%%~dp0arut.jar" %%*
    echo ^) else ^(
    echo     echo [ERROR] arut.jar not found.
    echo ^)
) > "%DIR_ALL_JAVA%\arut.cmd"

(
    echo #!/bin/sh
    echo DIR="$^(cd "$^(dirname "$0"^)" ^&^& pwd^)"
    echo export PATH="$DIR:$PATH"
    echo if [ -f "$DIR/arut.jar" ]; then
    echo     exec java -jar "$DIR/arut.jar" run
    echo else
    echo     echo "[ERROR] arut.jar not found."
    echo fi
) > "%DIR_ALL_JAVA%\arut-run"

(
    echo #!/bin/sh
    echo DIR="$^(cd "$^(dirname "$0"^)" ^&^& pwd^)"
    echo export PATH="$DIR:$PATH"
    echo if [ -f "$DIR/arut.jar" ]; then
    echo     exec java -jar "$DIR/arut.jar" "$@"
    echo else
    echo     echo "[ERROR] arut.jar not found."
    echo fi
) > "%DIR_ALL_JAVA%\arut.sh"

echo.
echo ========================================================
echo   Release Bundles Ready for Zipping / Publishing:
echo   - dist\windows\arut-rust-win64-%VERSION%\
echo   - dist\windows\arut-java-win64-%VERSION%\
echo   - dist\linux\arut-rust-linux64-%VERSION%\
echo   - dist\linux\arut-java-linux64-%VERSION%\
echo   - dist\macos\arut-rust-macos64-%VERSION%\
echo   - dist\macos\arut-java-macos64-%VERSION%\
echo   - dist\all-platform\arut-rust-all-%VERSION%\
echo   - dist\all-platform\arut-java-all-%VERSION%\
echo ========================================================
pause
