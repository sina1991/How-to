# Restore the existing master key securely before running. Never generates keys.
$ErrorActionPreference = 'Stop'
$key = Join-Path $env:USERPROFILE '.ssh\30na_windows'
if (!(Test-Path -LiteralPath $key -PathType Leaf) -or !(Test-Path -LiteralPath "$key.pub" -PathType Leaf)) {
    throw 'Restore the original master key pair from encrypted backup first. No new key generated.'
}
$public = (& ssh-keygen -y -f $key)
if ($LASTEXITCODE -ne 0) { throw 'Unable to read private key' }
$stored = (Get-Content -LiteralPath "$key.pub" -Raw).Trim()
if ((($public -split '\s+')[0..1] -join ' ') -ne (($stored -split '\s+')[0..1] -join ' ')) { throw 'Key pair mismatch' }
ssh-keygen -lf "$key.pub"
if ($LASTEXITCODE -ne 0) { throw 'Invalid public key' }
if ((Get-Service ssh-agent).Status -ne 'Running') { throw 'Start ssh-agent in elevated PowerShell first' }
ssh-add $key
if ($LASTEXITCODE -ne 0) { throw 'ssh-add failed' }
Get-Content -LiteralPath "$key.pub" | Set-Clipboard
ssh-add -l
Write-Host 'Existing master key loaded. Public key copied.'
