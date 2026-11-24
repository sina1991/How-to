$ErrorActionPreference = 'Stop'
Write-Host '=== 30nA SSH BACKUP ===' -ForegroundColor Cyan
$seven = Join-Path $env:ProgramFiles '7-Zip\7z.exe'
if (!(Test-Path -LiteralPath $seven)) {
    $cmd = Get-Command 7z.exe -ErrorAction SilentlyContinue
    if ($cmd) { $seven = $cmd.Source } else {
        if (!(Get-Command winget.exe -ErrorAction SilentlyContinue)) { throw 'Install 7-Zip from https://7-zip.org and rerun.' }
        winget install --id 7zip.7zip -e --accept-package-agreements --accept-source-agreements
        if (!(Test-Path -LiteralPath $seven)) { throw '7-Zip installation incomplete' }
    }
}
$key = Join-Path $env:USERPROFILE '.ssh\30na_windows'
if (!(Test-Path -LiteralPath $key -PathType Leaf) -or !(Test-Path -LiteralPath "$key.pub" -PathType Leaf)) { throw 'Existing master key pair not found; no new key generated' }
$folder = Join-Path $env:USERPROFILE 'Downloads'
New-Item -ItemType Directory -Force $folder | Out-Null
$zip = Join-Path $folder '30na-SSH-Backup.zip'
if (Test-Path -LiteralPath $zip) { throw 'Backup already exists. Move it to a safe place before creating a new one.' }
Write-Host 'Choose a strong ZIP password at the prompt.' -ForegroundColor Yellow
& $seven a -tzip -mem=AES256 -p $zip $key "$key.pub"
if ($LASTEXITCODE -ne 0) { throw 'Archive creation failed' }
Write-Host 'Confirm password by testing the new archive.' -ForegroundColor Yellow
& $seven t $zip
if ($LASTEXITCODE -ne 0) { throw 'Archive verification failed; do not rely on this backup' }
Write-Host "Backup verified: $zip" -ForegroundColor Green
