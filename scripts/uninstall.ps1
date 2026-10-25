# Removes auto-login and deletes the saved login from this PC.
param(
    [string]$InstallDir = (Join-Path $env:LOCALAPPDATA 'HostelWifiAutoLogin'),
    [string]$TaskName   = 'Hostel WiFi Auto Login'
)
Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false -ErrorAction SilentlyContinue
$menu = Join-Path ([Environment]::GetFolderPath('Programs')) 'Hostel WiFi Auto-Login'
if (Test-Path $menu) { Remove-Item $menu -Recurse -Force -ErrorAction SilentlyContinue }
# Delete the folder a moment later, once the window running Uninstall.bat has closed.
if (Test-Path $InstallDir) {
    $full = (Resolve-Path $InstallDir).Path
    Start-Process cmd.exe -WindowStyle Hidden -ArgumentList "/c ping -n 6 127.0.0.1 >nul & rd /s /q `"$full`""
}
Write-Host 'Removed. Auto-login is off and your saved login has been deleted from this PC.' -ForegroundColor Green
