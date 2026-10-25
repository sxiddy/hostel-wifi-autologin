@echo off
title Hostel WiFi Auto-Login - Uninstall
copy /y "%~dp0uninstall.ps1" "%TEMP%\hwal_uninstall.ps1" >nul
powershell -NoProfile -ExecutionPolicy Bypass -File "%TEMP%\hwal_uninstall.ps1" -InstallDir "%~dp0."
del "%TEMP%\hwal_uninstall.ps1" >nul 2>&1
echo. & pause & exit
