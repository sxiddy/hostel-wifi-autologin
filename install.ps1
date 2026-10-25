# Registers the auto-login as a Windows scheduled task (runs at logon and on every Wi-Fi connect).
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$script = Join-Path $here 'wifi_login.ps1'
if (-not (Test-Path (Join-Path $here 'cred.xml'))) { & (Join-Path $here 'setup.ps1') }

$action = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument "-NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File `"$script`""
$logon  = New-ScheduledTaskTrigger -AtLogOn
$wifi   = (Get-CimClass -Namespace Root/Microsoft/Windows/TaskScheduler -ClassName MSFT_TaskEventTrigger) | New-CimInstance -ClientOnly
$wifi.Enabled = $true
$wifi.Subscription = '<QueryList><Query Id="0" Path="Microsoft-Windows-WLAN-AutoConfig/Operational"><Select Path="Microsoft-Windows-WLAN-AutoConfig/Operational">*[System[EventID=8001]]</Select></Query></QueryList>'
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable
Register-ScheduledTask -TaskName 'Hostel WiFi Auto Login' -Action $action -Trigger @($logon, $wifi) -Settings $settings -Force | Out-Null
Write-Host 'Installed. You will now be signed in automatically whenever you join Q-VIT.'
