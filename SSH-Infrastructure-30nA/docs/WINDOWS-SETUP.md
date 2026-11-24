# Windows PowerShell

Run in Windows, not inside an SSH session.
```powershell
clear; ssh -V; Get-Service ssh-agent
```
Create a device-specific key using the root install.ps1 script, or run:
```powershell
clear; New-Item -ItemType Directory -Force "$env:USERPROFILE\.ssh" | Out-Null; ssh-keygen -t ed25519 -a 100 -C "30na-$env:COMPUTERNAME" -f "$env:USERPROFILE\.ssh\30na_windows"
```
Never overwrite an existing key. Use a passphrase. If ssh-agent is stopped, run `Set-Service ssh-agent -StartupType Automatic; Start-Service ssh-agent` in elevated PowerShell. Then in your normal session:
```powershell
clear; ssh-add "$env:USERPROFILE\.ssh\30na_windows"; ssh-add -l; Get-Content "$env:USERPROFILE\.ssh\30na_windows.pub" | Set-Clipboard
```
Install only the public key via a trusted existing session or console using install.sh. Verify server host fingerprint on its trusted console with `ssh-keygen -lf /etc/ssh/ssh_host_ed25519_key.pub`. Compare before accepting.
```powershell
ssh -i "$env:USERPROFILE\.ssh\30na_windows" -o IdentitiesOnly=yes -o PasswordAuthentication=no -o KbdInteractiveAuthentication=no root@server.example.com
```
For another computer repeat with a new key. Do not share private keys. A host key change requires independent verification before backing up known_hosts and removing the exact stale entry with ssh-keygen -R. Never disable host verification.
