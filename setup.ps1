# Run once: saves your hostel Wi-Fi login (encrypted, only your Windows account can read it).
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$c = Get-Credential -Message 'Enter your hostel Wi-Fi username and password'
if ($c) { $c | Export-Clixml (Join-Path $here 'cred.xml'); Write-Host 'Saved. Testing login...'; & (Join-Path $here 'wifi_login.ps1'); Get-Content (Join-Path $here 'log.txt') -Tail 3 -ErrorAction SilentlyContinue }
Read-Host 'Press Enter to close'
