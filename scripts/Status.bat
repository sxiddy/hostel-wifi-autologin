@echo off
title Hostel WiFi Auto-Login - Status
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0status.ps1" -InstallDir "%~dp0."
echo.
pause