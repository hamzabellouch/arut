@echo off
if exist "%~dp0arut.exe" (
    "%~dp0arut.exe" run
) else (
    echo ======================================================================
    echo [ERROR] 'arut.exe' (Rust binary) was not found in this folder.
    echo.
    echo 1. To run with Java (installed on your system), please open:
    echo    dist\all-platform\arut-run.cmd
    echo.
    echo 2. To compile 'arut.exe' with Rust, install Rust (cargo) from:
    echo    https://rustup.rs/ and run 'build-dist.cmd'.
    echo ======================================================================
)
pause
