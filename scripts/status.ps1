# Shows whether auto-login is installed and working.
param(
    [string]$InstallDir = $PSScriptRoot,
    [string]$TaskName   = 'Hostel WiFi Auto Login'
)
if (-not (Test-Path (Join-Path $InstallDir 'cred.xml'))) {
    $InstallDir = Join-Path $env:LOCALAPPDATA 'HostelWifiAutoLogin'
}

function Line($label, $value, $color = 'White') { Write-Host ('{0,-18}' -f $label) -NoNewline; Write-Host $value -ForegroundColor $color }

Write-Host ''
$task = Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue
if ($task) { Line 'Auto-login:' 'installed' 'Green' } else { Line 'Auto-login:' 'NOT installed (double-click Install.bat)' 'Red' }

Line 'Saved login:' $(if (Test-Path (Join-Path $InstallDir 'cred.xml')) { 'yes' } else { 'no (run Install.bat)' })

$net = (netsh wlan show interfaces | Select-String '^\s*SSID\s*:\s*(.+)$' | Select-Object -First 1)
Line 'Wi-Fi network:' $(if ($net) { $net.Matches.Groups[1].Value.Trim() } else { 'not connected' })

try {
    $ok = (Invoke-WebRequest 'http://www.msftconnecttest.com/connecttest.txt' -UseBasicParsing -TimeoutSec 5).Content -eq 'Microsoft Connect Test'
} catch { $ok = $false }
Line 'Internet:' $(if ($ok) { 'working' } else { 'not working' }) $(if ($ok) { 'Green' } else { 'Yellow' })

$log = Join-Path $InstallDir 'log.txt'
Write-Host ''
if (Test-Path $log) {
    Write-Host 'Recent activity:'
    Get-Content $log -Tail 8 | ForEach-Object { Write-Host "  $_" }
} else {
    Write-Host 'No activity yet. It only writes here when it has to sign you in.'
}
