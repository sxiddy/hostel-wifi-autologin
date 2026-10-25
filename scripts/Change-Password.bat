@echo off
title Hostel WiFi Auto-Login - Change password
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0setup.ps1" -Dir "%~dp0."
echo.
pause