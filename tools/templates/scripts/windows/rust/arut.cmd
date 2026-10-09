@echo off
if exist "%~dp0arut.exe" (
    "%~dp0arut.exe" %*
) else (
    echo [ERROR] arut.exe native binary not found.
)
