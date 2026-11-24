param([string]$ZipPath)
$ErrorActionPreference = 'Stop'
$seven = Join-Path $env:ProgramFiles '7-Zip\7z.exe'
if (!(Test-Path -LiteralPath $seven)) {
    $cmd = Get-Command 7z.exe -ErrorAction SilentlyContinue
    if (!$cmd) { throw 'Install 7-Zip first: winget install --id 7zip.7zip -e' }
    $seven = $cmd.Source
}
Get-Command ssh-keygen, ssh-add | Out-Null
Write-Host '=== 30nA SSH RESTORE v2 ===' -ForegroundColor Cyan
$default = Join-Path $env:USERPROFILE 'Downloads\30na-SSH-Backup.zip'
if (Test-Path (Join-Path $env:USERPROFILE '30na-SSH-Backup.zip')) { $default = Join-Path $env:USERPROFILE '30na-SSH-Backup.zip' }
if (Test-Path '.\30na-SSH-Backup.zip') { $default = '.\30na-SSH-Backup.zip' }
if (!$ZipPath) { $ZipPath = Read-Host "ZIP path [$default]"; if (!$ZipPath) { $ZipPath = $default } }
$ZipPath = (Resolve-Path -LiteralPath $ZipPath).Path
if (!(Test-Path -LiteralPath $ZipPath -PathType Leaf)) { throw 'ZIP not found' }
$dir = Join-Path $env:USERPROFILE '.ssh'
New-Item -ItemType Directory -Force $dir | Out-Null
if ((Get-Item -LiteralPath $dir -Force).Attributes -band [IO.FileAttributes]::ReparsePoint) { throw 'Refusing reparse point .ssh' }
$tmp = Join-Path $dir ('.30na-restore.' + [guid]::NewGuid())
New-Item -ItemType Directory $tmp | Out-Null
$sid = [Security.Principal.WindowsIdentity]::GetCurrent().User.Value
try {
    & icacls $tmp /inheritance:r /grant:r "*${sid}:(OI)(CI)F" | Out-Null
    if ($LASTEXITCODE -ne 0) { throw 'Unable to secure temporary directory' }
    Write-Host '[1/3] Enter ZIP password (not SSH passphrase).' -ForegroundColor Yellow
    & $seven e -y "-o$tmp" -- $ZipPath 30na_windows 30na_windows.pub
    if ($LASTEXITCODE -ne 0) { throw 'Extraction failed. Check ZIP password or archive integrity. No keys installed.' }
    Write-Host '[2/3] Validating key pair' -ForegroundColor Cyan
    $key = Join-Path $tmp '30na_windows'
    $dest = Join-Path $dir '30na_windows'
    foreach ($p in @($key, "$key.pub")) {
        if (!(Test-Path -LiteralPath $p -PathType Leaf) -or ((Get-Item -LiteralPath $p -Force).Attributes -band [IO.FileAttributes]::ReparsePoint)) { throw 'Missing or invalid archive member' }
        & icacls $p /inheritance:r /grant:r "*${sid}:(F)" | Out-Null
        if ($LASTEXITCODE -ne 0) { throw 'Unable to secure key file' }
    }
    $derived = & ssh-keygen -y -f $key
    if ($LASTEXITCODE -ne 0) { throw 'Invalid private key or passphrase' }
    $stored = (Get-Content -LiteralPath "$key.pub" -Raw).Trim()
    if ($stored -notmatch '^ssh-ed25519\s+' -or (($derived -split '\s+')[0..1] -join ' ') -ne (($stored -split '\s+')[0..1] -join ' ')) { throw 'Key pair mismatch' }
    ssh-keygen -lf "$key.pub"
    if ($LASTEXITCODE -ne 0) { throw 'Invalid public key' }
    foreach ($p in @($dest, "$dest.pub")) {
        if ((Test-Path -LiteralPath $p) -and ((Get-Item -LiteralPath $p -Force).Attributes -band [IO.FileAttributes]::ReparsePoint)) { throw 'Refusing reparse point destination' }
    }
    if ((Test-Path -LiteralPath $dest) -or (Test-Path -LiteralPath "$dest.pub")) {
        foreach ($suffix in @('', '.pub')) {
            if (!(Test-Path -LiteralPath "$dest$suffix" -PathType Leaf) -or (Get-FileHash -LiteralPath "$dest$suffix").Hash -ne (Get-FileHash -LiteralPath "$key$suffix").Hash) { throw 'Existing key differs or is incomplete; no overwrite' }
        }
    } else {
        [IO.File]::Move($key, $dest)
        try { [IO.File]::Move("$key.pub", "$dest.pub") } catch { Remove-Item -LiteralPath $dest; throw }
    }
    if ((Get-Service ssh-agent).Status -ne 'Running') {
        Write-Warning 'Key restored. In elevated PowerShell run: Set-Service ssh-agent -StartupType Automatic; Start-Service ssh-agent. Then in normal PowerShell run ssh-add on the restored key.'
    } else {
        ssh-add $dest
        if ($LASTEXITCODE -ne 0) { throw 'Key restored but ssh-add failed' }
        ssh-add -l
    }
    Write-Host '[3/3] Key restored. Connect: ssh root@VPS_IP' -ForegroundColor Green
} finally {
    Remove-Item -LiteralPath $tmp -Recurse -Force
}
