# 🔐 SSH Infrastructure — 30nA

**یک کلید مشترک، تمام VPSها، تمام حساب‌ها و دستگاه‌های مورد اعتماد.**

> [!IMPORTANT]
> فایل ZIP و رمز آن فقط نزد خودتان بماند. روی کامپیوتر عمومی از Termius موبایل استفاده کنید.

## 🟦 ۱. ساخت Backup — Windows اصلی

اگر 7-Zip نصب نیست:
```powershell
winget install --id 7zip.7zip -e
```
در PowerShell، یکجا اجرا کنید. نام فایل ZIP جدید باید آزاد باشد.
```powershell
clear; $z = "$env:USERPROFILE\Downloads\30na-SSH-Backup.zip"; if (Test-Path $z) { throw "Archive exists; move it first" }; & "$env:ProgramFiles\7-Zip\7z.exe" a -tzip -mem=AES256 -p $z "$env:USERPROFILE\.ssh\30na_windows" "$env:USERPROFILE\.ssh\30na_windows.pub"; if ($LASTEXITCODE -ne 0) { throw "Backup failed" }
```
رمز طولانی و تصادفی را هنگام درخواست وارد کنید. برای تست رمز:
```powershell
clear; & "$env:ProgramFiles\7-Zip\7z.exe" t "$env:USERPROFILE\Downloads\30na-SSH-Backup.zip"
```
باید Everything is Ok نمایش داده شود. ZIP را در محل امن نگهداری کنید.

## 🟩 ۲. نصب روی Ubuntu/Linux جدید

ZIP را در پوشه فعلی یا Home یا Downloads قرار دهید. اگر جای دیگری است مسیر کامل را هنگام درخواست وارد کنید.

در Ubuntu، یک بار پیش‌نیازها را نصب کنید (اگر root هستید sudo را حذف کنید):
```bash
sudo apt-get update && sudo apt-get install -y curl openssh-client p7zip-full
```

**دستور نصب — یکجا کپی کنید:**
```bash
clear
f=$(mktemp) && curl -fsSL https://raw.githubusercontent.com/sina1991/How-to/main/SSH-Infrastructure-30nA/install.sh -o "$f" && bash "$f" && eval "$(ssh-agent -s)" && ssh-add ~/.ssh/30na_windows
```
- ZIP path: Enter برای مسیر پیشنهادی یا مسیر کامل فایل.
- Enter password: رمز ZIP (نه Password سرور).
- اگر SSH Passphrase درخواست شد، رمز خود کلید را وارد کنید.
- خروجی موفق: Key restored successfully و Identity added.

اتصال:
```bash
ssh root@VPS_IP
```
در نشست جدید اگر Agent در دسترس نیست، از ssh -i ~/.ssh/30na_windows root@VPS_IP استفاده کنید یا Agent را دوباره فعال کنید.

## 🟦 ۳. نصب روی Windows جدید

OpenSSH Client و 7-Zip لازم است. ZIP را در Downloads، Home یا پوشه فعلی بگذارید. در PowerShell عادی دستور زیر را یکجا اجرا کنید:
```powershell
clear; $p = Join-Path $env:TEMP "30na-install.ps1"; Invoke-WebRequest "https://raw.githubusercontent.com/sina1991/How-to/main/SSH-Infrastructure-30nA/install.ps1" -OutFile $p -ErrorAction Stop; powershell.exe -NoProfile -ExecutionPolicy Bypass -File $p
```
اگر Agent متوقف است، در PowerShell Administrator:
```powershell
clear; Set-Service ssh-agent -StartupType Automatic; Start-Service ssh-agent
```
سپس در PowerShell عادی:
```powershell
clear; ssh-add "$env:USERPROFILE\.ssh\30na_windows"; ssh-add -l
```
اتصال: ssh root@VPS_IP.

## 🟪 ۴. Termius و VPS جدید

- [Termius: Import همان Private Key](docs/TERMIUS-SETUP.md)
- [Doprax و دیگر سرویس‌دهندگان: ثبت Public Key](docs/VPS-PROVIDERS.md)

هنگام ایجاد VPS همان Public Key را انتخاب کنید. نام کاربری ممکن است ubuntu باشد. Host Key سرور را از Console معتبر بررسی کنید.

## 🟥 ۵. خطاها

| خطا | راه حل |
|---|---|
| ZIP not found | مسیر کامل فایل ZIP را وارد کنید، نه رمز |
| Wrong password | رمز واقعی ZIP را بررسی کنید؛ نصب‌کننده v2 رمز را از طریق 7-Zip می‌پرسد |
| Existing key differs | فایل قبلی را حذف نکنید؛ ابتدا Fingerprint را بررسی کنید |
| Permission denied (publickey) | کلید عمومی باید روی کاربر مقصد نصب شده باشد |
| Host key changed | Fingerprint جدید را مستقل بررسی کنید؛ اعتبارسنجی را غیرفعال نکنید |

## سایر راهنماها

[Windows](docs/WINDOWS-SETUP.md) · [Recovery](docs/RECOVERY.md) · [Linux / Tunnel](docs/SERVER-TO-SERVER.md)

برای افزودن فقط Public Key به VPS موجود: bash install-public-key.sh /path/to/30na_windows.pub. نصب‌کننده‌های ZIP سرویس SSH و Tunnelها را تغییر نمی‌دهند. این مدل ریسک مشترک دارد؛ افشای یک کلید خصوصی همه سرورها را در معرض خطر قرار می‌دهد. هیچ کلید یا رمز واقعی در مخزن ثبت نمی‌شود. تست عملی نسخه v2 روی دستگاه کاربر هنوز باقی است.
