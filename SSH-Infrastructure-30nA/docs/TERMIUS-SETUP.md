# Termius — Android, iOS and Desktop

Download: https://termius.com/download
1. Open Keychain/Keys (labels vary by platform/version), generate an Ed25519 key named 30na-termius-device, protect it with a passphrase.
2. Copy/export its public key only. Through an existing trusted admin connection save the public key as a temporary file on the destination and run `bash install.sh /path/to/client.pub` as the destination login user.
3. Add a Host: address server.example.com (or verified IP), port 22, username root if that is the existing account, authentication key 30na-termius-device. Leave password blank.
4. Verify the host fingerprint independently via provider console: `ssh-keygen -lf /etc/ssh/ssh_host_ed25519_key.pub`. Accept only a match. Connect and run `whoami; hostname -I`.
5. Repeat for each server. Prefer individual keys per device. If using Termius vault synchronization, review account security and whether private keys are synchronized. Avoid importing the primary Windows private key. Never send keys via chat or email.
6. If a device is lost, remove its matching public key from authorized_keys on all destinations using a trusted remaining session and backup first. Do not remove other keys.

Permission denied (publickey) means authentication failed; verify the selected key, account and authorized_keys permissions. Host key errors are separate; never bypass them.
