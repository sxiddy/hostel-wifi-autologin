# Logs in to any VIT campus/hostel Wi-Fi (Q-VIT, G-VIT 5, VIT-Hostel, ...) portal automatically.
# Every VIT network shares one portal and one login, so a single script covers all blocks.
# Matches any network whose name contains this text; change it only if your block's name differs.
$ssidMatch = 'VIT'
$here    = Split-Path -Parent $MyInvocation.MyCommand.Path
$credFile = Join-Path $here 'cred.xml'
$log     = Join-Path $here 'log.txt'
function Log($m) { "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')  $m" | Out-File $log -Append -Encoding utf8 }

$cur = (netsh wlan show interfaces | Select-String '^\s*SSID\s*:\s*(.+)$' | Select-Object -First 1).Matches.Groups[1].Value.Trim()
if (-not $cur -or $cur -notlike "*$ssidMatch*") { exit }
if (-not (Test-Path $credFile)) { Log 'No saved login. Run setup.ps1 first.'; exit }
$cred = Import-Clixml $credFile

for ($i = 1; $i -le 6; $i++) {
    try {
        $t = (Invoke-WebRequest 'http://www.msftconnecttest.com/connecttest.txt' -UseBasicParsing -TimeoutSec 5).Content
        if ($t -eq 'Microsoft Connect Test') { if ($i -gt 1) { Log 'Online.' }; exit }
    } catch {}
    try {
        $body = @{ userId = $cred.UserName; password = $cred.GetNetworkCredential().Password; serviceName = 'ProntoAuthentication' }
        $r = Invoke-WebRequest 'http://phc.prontonetworks.com/cgi-bin/authlogin?URI=http://example.com' -Method Post -Body $body -UseBasicParsing -TimeoutSec 10
        if ($r.Content -match 'Access Granted') { Log 'Logged in.'; exit }
        Log "Attempt ${i}: portal did not grant access."
    } catch { Log "Attempt ${i}: $($_.Exception.Message)" }
    Start-Sleep -Seconds 5
}

