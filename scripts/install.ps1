# One-step installer: copies the scripts to a permanent folder, saves your login, and sets up auto-login.
param(
    [string]$InstallDir = (Join-Path $env:LOCALAPPDATA 'HostelWifiAutoLogin'),
    [string]$TaskName   = 'Hostel WiFi Auto Login'
)
$ErrorActionPreference = 'Stop'
$src = $PSScriptRoot

function Step($m) { Write-Host ''; Write-Host $m -ForegroundColor Cyan }
function Ok($m)   { Write-Host "  OK  $m" -ForegroundColor Green }

try {
    Write-Host '=============================================' -ForegroundColor Cyan
    Write-Host '   Hostel WiFi Auto-Login  -  Setup'            -ForegroundColor Cyan
    Write-Host '=============================================' -ForegroundColor Cyan

    if ($PSVersionTable.PSVersion.Major -lt 5) { throw 'This needs Windows 10 or 11 (PowerShell 5 or newer).' }

    Step '1/4  Copying files to a safe place...'
    New-Item -ItemType Directory -Force $InstallDir | Out-Null
    foreach ($f in Get-ChildItem $src -File | Where-Object { $_.Name -ne 'install.ps1' }) {
        Copy-Item $f.FullName (Join-Path $InstallDir $f.Name) -Force
        Unblock-File (Join-Path $InstallDir $f.Name) -ErrorAction SilentlyContinue
    }
    Ok ($InstallDir -replace [regex]::Escape($env:LOCALAPPDATA), '%LOCALAPPDATA%')
    Write-Host '      (You can now delete the downloaded folder if you like.)'

    # Start Menu shortcuts so beginners never need to find files again.
    $menu = Join-Path ([Environment]::GetFolderPath('Programs')) 'Hostel WiFi Auto-Login'
    New-Item -ItemType Directory -Force $menu | Out-Null
    $sh = New-Object -ComObject WScript.Shell
    foreach ($s in @(@('Check status', 'Status.bat'), @('Change password', 'Change-Password.bat'), @('Uninstall', 'Uninstall.bat'))) {
        $lnk = $sh.CreateShortcut((Join-Path $menu "$($s[0]).lnk"))
        $lnk.TargetPath = Join-Path $InstallDir $s[1]
        $lnk.WorkingDirectory = $env:TEMP
        $lnk.Save()
    }

    Step '2/4  Saving your hostel Wi-Fi login...'
    $credFile = Join-Path $InstallDir 'cred.xml'
    if (Test-Path $credFile) {
        Ok 'A saved login already exists, keeping it. (Use Change password to replace it.)'
    } else {
        & (Join-Path $InstallDir 'setup.ps1') -Dir $InstallDir
    }

    Step '3/4  Turning on auto-login...'
    $script = Join-Path $InstallDir 'wifi_login.ps1'
    $action = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument "-NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File `"$script`""
    $logon  = New-ScheduledTaskTrigger -AtLogOn -User $env:USERNAME
    $wifi   = Get-CimClass -Namespace Root/Microsoft/Windows/TaskScheduler -ClassName MSFT_TaskEventTrigger | New-CimInstance -ClientOnly
    $wifi.Enabled = $true
    $wifi.Subscription = '<QueryList><Query Id="0" Path="Microsoft-Windows-WLAN-AutoConfig/Operational"><Select Path="Microsoft-Windows-WLAN-AutoConfig/Operational">*[System[EventID=8001]]</Select></Query></QueryList>'
    $settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable -ExecutionTimeLimit (New-TimeSpan -Minutes 5)
    Register-ScheduledTask -TaskName $TaskName -Action $action -Trigger @($logon, $wifi) -Settings $settings -Force | Out-Null
    Ok 'It will now run every time you connect to Wi-Fi or sign in to Windows.'

    Step '4/4  Trying it now...'
    $net = (netsh wlan show interfaces | Select-String '^\s*SSID\s*:\s*(.+)$' | Select-Object -First 1)
    $ssid = if ($net) { $net.Matches.Groups[1].Value.Trim() } else { '' }
    if (-not $ssid) {
        Write-Host '  You are not connected to Wi-Fi right now. That is fine.'
        Write-Host '  Connect to your hostel network and it will sign you in by itself.'
    } elseif ($ssid -notlike '*VIT*') {
        Write-Host "  You are on '$ssid', which is not a VIT network, so nothing to do yet."
        Write-Host '  Connect to your hostel network and it will sign you in by itself.'
    } else {
        $logFile = Join-Path $InstallDir 'log.txt'
        $before = if (Test-Path $logFile) { (Get-Content $logFile).Count } else { 0 }
        & powershell -NoProfile -ExecutionPolicy Bypass -File $script
        $new = if (Test-Path $logFile) { @(Get-Content $logFile | Select-Object -Skip $before) } else { @() }
        if ($new.Count -eq 0) {
            Ok "You are on '$ssid' and already online. Nothing needed."
        } elseif ($new[-1] -match 'Logged in|Online') {
            Ok "Signed in to '$ssid'."
        } else {
            Write-Host "  Could not sign in: $($new[-1])" -ForegroundColor Yellow
            Write-Host '  If the username or password was wrong, double-click scripts\Change-Password.bat'
            Write-Host '  (or later: Start menu > Hostel WiFi Auto-Login > Change password).'
        }
    }

    Write-Host ''
    Write-Host 'All done! You never need to log in to the hostel Wi-Fi by hand again.' -ForegroundColor Green
    Write-Host 'Find "Hostel WiFi Auto-Login" in your Start menu to check status, change your password, or uninstall.'
} catch {
    Write-Host ''
    Write-Host "Something went wrong: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host 'Please open an issue on GitHub and paste this message.'
    exit 1
}
