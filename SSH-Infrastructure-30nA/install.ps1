$ErrorActionPreference = 'Stop'
$dir = Join-Path $env:USERPROFILE '.ssh'
$key = Join-Path $dir '30na_windows'
New-Item -ItemType Directory -Force $dir | Out-Null
if (!(Test-Path $key) -and !(Test-Path "$key.pub")) {
    ssh-keygen -t ed25519 -a 100 -C "30na-$env:COMPUTERNAME" -f $key
    if ($LASTEXITCODE -ne 0) { throw 'Key generation failed' }
}
if (!(Test-Path $key) -or !(Test-Path "$key.pub")) { throw 'Incomplete key pair; inspect manually' }
ssh-keygen -lf "$key.pub"
Get-Content "$key.pub" | Set-Clipboard
Write-Host 'Public key copied. Install it on the destination using a trusted session.'
