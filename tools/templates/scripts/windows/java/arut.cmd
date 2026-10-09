@echo off
if exist "%~dp0arut.jar" (
    java -jar "%~dp0arut.jar" %*
) else (
    echo [ERROR] arut.jar not found.
)
