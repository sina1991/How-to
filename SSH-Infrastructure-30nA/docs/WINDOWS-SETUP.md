# Windows — راهنمای عملی

## کامپیوتر فعلی
PowerShell ویندوز (نه Ubuntu):
```powershell
clear; ssh-add -l; ssh-keygen -lf "$env:USERPROFILE\.ssh\30na_windows.pub"
```
برای اتصال:
```powershell
ssh root@VPS_IP
```
اگر کلید انتخاب نشد:
```powershell
ssh -i "$env:USERPROFILE\.ssh\30na_windows" -o IdentitiesOnly=yes root@VPS_IP
```

## کامپیوتر جدید مورد اعتماد
۱. OpenSSH Client را بررسی کنید: ssh -V.
۲. از Backup رمزگذاری‌شده، همان Private Key و Public Key را در پوشه .ssh حساب کاربری بازیابی کنید. کلید جدید نسازید. اگر فایلی با همان نام وجود دارد، ابتدا Fingerprint را بررسی کنید و آن را بازنویسی نکنید.
۳. در PowerShell با Run as Administrator در صورت نیاز:
```powershell
clear; Set-Service ssh-agent -StartupType Automatic; Start-Service ssh-agent
```
۴. در PowerShell عادی، از پوشه مخزن:
```powershell
clear; .\install.ps1
```
اسکریپت کلید موجود را بررسی و در Agent بارگذاری می‌کند؛ اگر کلید نیست متوقف می‌شود. هیچ کلید تازه‌ای نمی‌سازد.
۵. به VPS متصل شوید. اگر سرویس‌دهنده کاربر ubuntu دارد، به جای root از ubuntu استفاده کنید. کلید Host را با Console معتبر مقایسه کنید.

## کپی Public Key برای حساب VPS جدید
```powershell
clear; Get-Content "$env:USERPROFILE\.ssh\30na_windows.pub" | Set-Clipboard
```
فقط همین فایل عمومی را در پنل قرار دهید.

## خطای Host Key بعد از ساخت VPS جدید
در Console سرویس‌دهنده: ssh-keygen -lf /etc/ssh/ssh_host_ed25519_key.pub
در صورت تطبیق قطعی Fingerprint جدید و پس از Backup فایل known_hosts، فقط رکورد مقصد تغییرکرده را با ssh-keygen -R VPS_IP حذف کنید. مجدداً اتصال و Fingerprint را بررسی کنید. هرگز StrictHostKeyChecking=no استفاده نکنید.
