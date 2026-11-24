# ثبت کلید در حساب‌های VPS و ساخت سرور جدید

## Doprax
۱. در Windows فایل عمومی را کپی کنید:
```powershell
clear; Get-Content "$env:USERPROFILE\.ssh\30na_windows.pub" | Set-Clipboard
```
۲. وارد https://www.doprax.com/v/services/virtual-machines/ssh-keys/ شوید.
۳. Public Key را با عنوان 30na-windows-admin ثبت کنید.
۴. Fingerprint پنل را با خروجی ssh-keygen -lf "$env:USERPROFILE\.ssh\30na_windows.pub" تطبیق دهید.
۵. همین مراحل را در هر حساب جدید تکرار کنید؛ کلید جدید تولید نکنید.
۶. هنگام ایجاد VM، در صورت وجود گزینه SSH Keys همان کلید را انتخاب کنید. بررسی کنید Image و ارائه‌دهنده کلید را برای کدام کاربر نصب می‌کنند.
۷. IP جدید و Fingerprint سرور را از Console معتبر بررسی کنید. سپس با ssh root@VPS_IP یا نام کاربری اعلام‌شده متصل شوید. در Termius همان Key قبلی را انتخاب کنید.

## سایر ارائه‌دهندگان
در بخش SSH Keys، همان Public Key را ثبت و هنگام Provisioning انتخاب کنید. اگر این قابلیت وجود ندارد، با Console یا روش اولیه ورود، Public Key را در authorized_keys کاربر مقصد نصب کنید (install-public-key.sh). ثبت کلید در پنل لزوماً سرورهای موجود را تغییر نمی‌دهد. Last used نیز به تنهایی اثبات ورود موفق نیست.

## حذف یا نصب مجدد سرور
برای استفاده از کلید مشترک نیازی به حذف VPS نیست. قبل از حذف، از داده‌ها، تنظیمات و سرویس‌ها Backup بگیرید. سرور جایگزین Host Key جدید دارد؛ هویت آن را مستقل بررسی کنید. کلید مدیریتی مشترک تغییر نمی‌کند.
