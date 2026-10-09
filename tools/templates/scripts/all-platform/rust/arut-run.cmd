@echo off
if exist "%~dp0arut.exe" (
    "%~dp0arut.exe" run
) else (
    echo [ERROR] arut.exe native binary not found.
)
pause
