# Asks for your hostel Wi-Fi login and saves it encrypted (only your Windows account on this PC can read it).
param([string]$Dir = $PSScriptRoot)

Write-Host ''
Write-Host 'Enter the login you normally type on the hostel Wi-Fi page.'
Write-Host '(Usually your registration number and your Wi-Fi password.)'
Write-Host 'Your password shows as **** while you type. That is normal.'
Write-Host ''

do {
    $user = (Read-Host 'Username').Trim()
    if (-not $user) { Write-Host 'Username cannot be empty, try again.' -ForegroundColor Yellow }
} until ($user)

do {
    $pass = Read-Host 'Password' -AsSecureString
    $plain = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($pass))
    if (-not $plain) { Write-Host 'Password cannot be empty, try again.' -ForegroundColor Yellow }
} until ($plain)

New-Object System.Management.Automation.PSCredential($user, $pass) | Export-Clixml (Join-Path $Dir 'cred.xml')
Write-Host ''
Write-Host 'Saved.' -ForegroundColor Green
