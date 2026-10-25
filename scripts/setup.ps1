# Asks for your hostel Wi-Fi login and saves it encrypted (only your Windows account on this PC can read it).
# Catches typos: the username is shown back for confirmation and the password is typed twice.
param([string]$Dir = $PSScriptRoot)

function Plain($s) { [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($s)) }

Write-Host ''
Write-Host 'Enter the login you normally type on the hostel Wi-Fi page.'
Write-Host '(Usually your registration number, like 21BCE1234, and your Wi-Fi password.)'
Write-Host 'Your password shows as **** while you type. That is normal.'

while ($true) {
    Write-Host ''
    do {
        $user = (Read-Host 'Username').Trim()
        if (-not $user) { Write-Host 'Username cannot be empty, try again.' -ForegroundColor Yellow }
    } until ($user)

    while ($true) {
        $pass = Read-Host 'Password' -AsSecureString
        if (-not (Plain $pass)) { Write-Host 'Password cannot be empty, try again.' -ForegroundColor Yellow; continue }
        $again = Read-Host 'Type the password again' -AsSecureString
        if ((Plain $pass) -ceq (Plain $again)) { break }
        Write-Host 'The two passwords did not match. Please type it again.' -ForegroundColor Yellow
    }

    Write-Host ''
    if ($user -notmatch '^\d{2}[A-Za-z]{3}\d{4,5}$') {
        Write-Host "Note: '$user' doesn't look like a registration number (like 21BCE1234)." -ForegroundColor Yellow
    }
    $ok = Read-Host "Username is '$user'. Is that right? (Y/N)"
    if ($ok -match '^\s*(y|yes)?\s*$') { break }
    Write-Host "No problem, let's try again." -ForegroundColor Yellow
}

New-Object System.Management.Automation.PSCredential($user, $pass) | Export-Clixml (Join-Path $Dir 'cred.xml')
# A new login clears any earlier "wrong password" stop.
Remove-Item (Join-Path $Dir 'badlogin.flag') -ErrorAction SilentlyContinue
Write-Host ''
Write-Host 'Saved.' -ForegroundColor Green
