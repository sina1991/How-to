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
از [راهنمای بازیابی ZIP](RECOVERY.md) و install.ps1 استفاده کنید. فایل ZIP را در Downloads قرار دهید یا مسیر کامل آن را وارد کنید. کلید جدید نسازید.

## کپی Public Key برای حساب VPS جدید
```powershell
clear; Get-Content "$env:USERPROFILE\.ssh\30na_windows.pub" | Set-Clipboard
```
فقط همین فایل عمومی را در پنل قرار دهید.

## خطای Host Key بعد از ساخت VPS جدید
در Console سرویس‌دهنده: ssh-keygen -lf /etc/ssh/ssh_host_ed25519_key.pub
در صورت تطبیق قطعی Fingerprint جدید و پس از Backup فایل known_hosts، فقط رکورد مقصد تغییرکرده را با ssh-keygen -R VPS_IP حذف کنید. مجدداً اتصال و Fingerprint را بررسی کنید. هرگز StrictHostKeyChecking=no استفاده نکنید.
