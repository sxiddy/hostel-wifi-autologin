# Logs in to any VIT campus/hostel Wi-Fi (Q-VIT, G-VIT 5, VIT-Hostel, ...) portal automatically.
# Every VIT network shares one portal and one login, so a single script covers all blocks.
# Matches any network whose name contains this text; change it only if your block's name differs.
$ssidMatch = 'VIT'
$here    = Split-Path -Parent $MyInvocation.MyCommand.Path
$credFile = Join-Path $here 'cred.xml'
$badFlag  = Join-Path $here 'badlogin.flag'
$log     = Join-Path $here 'log.txt'
function Log($m) { "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')  $m" | Out-File $log -Append -Encoding utf8 }

# Pops up a Windows notification for a few seconds.
function Notify($title, $text) {
    try {
        Add-Type -AssemblyName System.Windows.Forms, System.Drawing
        $n = New-Object System.Windows.Forms.NotifyIcon
        $n.Icon = [System.Drawing.SystemIcons]::Warning; $n.Visible = $true
        $n.ShowBalloonTip(15000, $title, $text, [System.Windows.Forms.ToolTipIcon]::Warning)
        Start-Sleep -Seconds 15; $n.Dispose()
    } catch {}
}
function Online {
    try { (Invoke-WebRequest 'http://www.msftconnecttest.com/connecttest.txt' -UseBasicParsing -TimeoutSec 5).Content -eq 'Microsoft Connect Test' } catch { $false }
}
$fixIt = 'Open the Start menu > Hostel WiFi Auto-Login > Change password.'

$cur = (netsh wlan show interfaces | Select-String '^\s*SSID\s*:\s*(.+)$' | Select-Object -First 1).Matches.Groups[1].Value.Trim()
if (-not $cur -or $cur -notlike "*$ssidMatch*") { exit }
if (-not (Test-Path $credFile)) { Log 'No saved login. Run setup.ps1 first.'; exit }
if (Online) { exit }

# The portal already rejected this login. Don't keep sending it (that can lock the account).
if (Test-Path $badFlag) {
    Log 'Skipped: the saved username or password is wrong. Waiting for Change password.'
    Notify 'Hostel Wi-Fi: wrong username or password' "Your saved login was rejected, so you were not signed in. $fixIt"
    exit
}
$cred = Import-Clixml $credFile

for ($i = 1; $i -le 6; $i++) {
    if ($i -gt 1 -and (Online)) { Log 'Online.'; exit }
    try {
        $body = @{ userId = $cred.UserName; password = $cred.GetNetworkCredential().Password; serviceName = 'ProntoAuthentication' }
        $r = Invoke-WebRequest 'http://phc.prontonetworks.com/cgi-bin/authlogin?URI=http://example.com' -Method Post -Body $body -UseBasicParsing -TimeoutSec 10
        if ($r.Content -match 'Access Granted') { Log 'Logged in.'; exit }
        if ($r.Content -match 'invalid|incorrect|wrong password|authentication failed|user not found|login failed') {
            New-Item $badFlag -ItemType File -Force | Out-Null
            Log "Wrong username or password. $fixIt"
            Notify 'Hostel Wi-Fi: wrong username or password' "The portal rejected your saved login for '$($cred.UserName)'. $fixIt"
            exit
        }
        if ($r.Content -match 'session limit|max session|account expired') {
            Log 'Portal refused: too many devices logged in, or the account has expired.'
            Notify 'Hostel Wi-Fi: login refused' 'Too many devices are logged in with your account, or it has expired. Log out on another device and reconnect.'
            exit
        }
        Log "Attempt ${i}: portal did not grant access."
    } catch { Log "Attempt ${i}: $($_.Exception.Message)" }
    Start-Sleep -Seconds 5
}
