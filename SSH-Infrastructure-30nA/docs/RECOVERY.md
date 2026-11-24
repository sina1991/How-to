# راهنمای سفر — بازیابی کلید مشترک از ZIP

فقط روی دستگاه مورد اعتماد اجرا کنید. روی کامپیوتر عمومی از Termius موبایل خود استفاده کنید.

## ۱. ساخت Backup روی Windows اصلی
پیش‌نیاز: 7-Zip (winget install --id 7zip.7zip -e).
```powershell
clear; $zip = "$env:USERPROFILE\Downloads\30na-SSH-Backup.zip"; if (Test-Path $zip) { throw "Backup already exists" }; & "$env:ProgramFiles\7-Zip\7z.exe" a -tzip -mem=AES256 -p $zip "$env:USERPROFILE\.ssh\30na_windows" "$env:USERPROFILE\.ssh\30na_windows.pub"
```
رمز طولانی تصادفی را در Prompt وارد کنید. رمز چهاررقمی برای Master Key امن نیست. رمز ZIP را با Passphrase کلید اشتباه نگیرید. رمز در دستور، GitHub یا History قرار نمی‌گیرد.
برای تست:
```powershell
clear; & "$env:ProgramFiles\7-Zip\7z.exe" t "$env:USERPROFILE\Downloads\30na-SSH-Backup.zip"
```
ZIP را در USB رمزگذاری‌شده یا محل امن نگهداری کنید. در GitHub آپلود نکنید.

## ۲. Windows جدید
OpenSSH Client و 7-Zip لازم است. فایل ZIP را در Downloads بگذارید یا مسیر کامل آن را وارد کنید. در PowerShell عادی:
```powershell
clear; $p = Join-Path $env:TEMP "30na-install.ps1"; Invoke-WebRequest "https://raw.githubusercontent.com/sina1991/How-to/main/SSH-Infrastructure-30nA/install.ps1" -OutFile $p; Get-Content $p
```
بعد از بررسی محتوای اسکریپت:
```powershell
clear; powershell.exe -NoProfile -ExecutionPolicy Bypass -File "$env:TEMP\30na-install.ps1"
```
ExecutionPolicy فقط برای همین فرایند تغییر می‌کند. مسیر ZIP را بدهید یا Enter بزنید. 7-Zip رمز را درخواست می‌کند. اگر Agent متوقف است، در PowerShell ادمین:
```powershell
clear; Set-Service ssh-agent -StartupType Automatic; Start-Service ssh-agent
```
سپس PowerShell عادی:
```powershell
clear; ssh-add "$env:USERPROFILE\.ssh\30na_windows"; ssh-add -l
```
اتصال: ssh root@VPS_IP. برای کلید مشخص از ssh -i "$env:USERPROFILE\.ssh\30na_windows" -o IdentitiesOnly=yes root@VPS_IP استفاده کنید.

## ۳. Ubuntu/Linux جدید
برای Ubuntu در صورت نیاز:
```bash
clear
sudo apt-get update && sudo apt-get install -y openssh-client p7zip-full curl
```
با کاربر عادی مقصد (نه sudo) اسکریپت را دانلود و بررسی کنید:
```bash
clear
curl -fL https://raw.githubusercontent.com/sina1991/How-to/main/SSH-Infrastructure-30nA/install.sh -o /tmp/30na-install.sh && cat /tmp/30na-install.sh
```
پس از بررسی:
```bash
clear
bash /tmp/30na-install.sh && eval "$(ssh-agent -s)" && ssh-add ~/.ssh/30na_windows
```
Enter برای مسیر پیش‌فرض ~/Downloads/30na-SSH-Backup.zip یا مسیر کامل دیگر. رمز ZIP در 7-Zip درخواست می‌شود. در صورت داشتن Passphrase، SSH آن را نیز درخواست می‌کند. Agent این Shell فعال است؛ در نشست بعدی ممکن است نیاز به بارگذاری دوباره داشته باشید.
اتصال: ssh root@VPS_IP.

## ۴. رفتار نصب
هر دو نصب‌کننده فقط دو فایل مورد انتظار را استخراج می‌کنند، تطابق Public/Private را بررسی می‌کنند، فایل موجود متفاوت را بازنویسی نمی‌کنند و فایل موقت را پاک می‌کنند. Fingerprint خروجی را با پنل سرویس‌دهنده مقایسه کنید. هیچ کلید جدیدی نمی‌سازند و تنظیمات SSH Server یا Tunnel را تغییر نمی‌دهند. اگر Host Key جدید است از Console ارائه‌دهنده مستقل بررسی کنید. اگر VPS بدون Public Key ساخته شده، از install-public-key.sh روی سرور مقصد استفاده کنید.

## ۵. Termius
روی دستگاه شخصی همان کلید خصوصی را از نسخه پشتیبان وارد کنید. روی دستگاه عمومی فایل ZIP یا رمز آن را وارد نکنید. اگر کلید خصوصی افشا شد، در همه سرورها و حساب‌های ارائه‌دهنده Rotate کنید. Public Key به تنهایی امکان بازیابی Private Key را نمی‌دهد.

وضعیت: اسکریپت‌های بازیابی جدید باید روی دستگاه مورد اعتماد با کلید آزمایشی و سپس Backup واقعی تست شوند.
