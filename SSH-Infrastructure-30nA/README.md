# SSH Infrastructure — 30nA

راهنمای دسترسی SSH با Windows، Termius و Linux. برای هر دستگاه کلید ED25519 مستقل بسازید. فقط Public Key را روی مقصد نصب کنید. هیچ Private Key یا تنظیمات واقعی زیرساخت را در این مخزن عمومی قرار ندهید.

- [Windows](docs/WINDOWS-SETUP.md)
- [Termius](docs/TERMIUS-SETUP.md)
- [Server-to-server and existing tunnels](docs/SERVER-TO-SERVER.md)

## Installation
On a trusted Ubuntu console, inspect install.sh, then run `bash install.sh /path/to/client.pub` as the target login user. It appends a public key, preserves existing keys and creates a backup. It never changes sshd configuration or restarts services. Keep existing sessions open and test a new connection before closing them.
On Windows, inspect install.ps1 and run it from PowerShell to generate a new independent key or display the existing public key. No aliases are required.
