# Linux server-to-server

Existing production tunnels must remain running. Do not reinstall, restart sshd, replace keys or change systemd units to fix a new destination's publickey error.
Read-only inspection:
```bash
clear
systemctl list-units 'ssh-tunnel-*.service' --all
systemctl cat ssh-tunnel-1.service
ssh -G root@server.example.com | grep -E '^(identityfile|user|hostname|port) '
ls -la ~/.ssh
```
A successful tunnel to one destination does not grant access to another. Generate a separate key for new unattended tunnels only after inspecting current identities. For unattended services a dedicated unencrypted key may be needed; restrict the destination authorized_keys entry to the required forwarding destination, source address where stable, and no interactive privileges where feasible. Do not change working tunnel keys. Validate new host fingerprints independently and test a new connection without disrupting existing services. Back up configuration and keys securely outside the public repository before any migration. Actual production changes are not yet tested.
