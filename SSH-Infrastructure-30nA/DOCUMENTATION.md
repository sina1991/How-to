# دفترچه راهنمای SSH — 30nA

## فهرست
- [۱. آماده‌سازی](#prepare)
- [۲. استخراج کلیدها](#extract)
- [۳. نصب Linux](#install)
- [۴. اتصال به VPS](#connect)
- [۵. سرور دارای Password](#password)
- [۶. امنیت و خطاها](#security)
- [۷. Windows](#windows)
- [۸. Termius](#termius)

<a name="prepare"></a>
## ۱. آماده‌سازی
روی Ubuntu/Debian مبدأ با کاربر مورد نظر (مثلاً root) فایل 30na-SSH-Backup.zip را در Home قرار دهید. curl و bash برای دریافت اولیه لازم هستند؛ apt update و نصب بسته‌ها داخل اسکریپت‌ها انجام می‌شود. کاربر غیر root به sudo نیاز دارد.

<a name="extract"></a>
## ۲. استخراج کلیدها
```bash
curl -fsSL https://raw.githubusercontent.com/sina1991/How-to/main/SSH-Infrastructure-30nA/unzip.sh | bash
```
اسکریپت ابتدا بسته‌ها را به‌روز و پیش‌نیازها را نصب می‌کند. اگر جفت کلید Home معتبر باشد، Public Key و Fingerprint را نشان می‌دهد. برای نمایش Private Key روی ترمینال شخصی گزینه y را انتخاب کنید؛ پیش‌فرض عدم نمایش است. سپس برای تأیید کلیدهای موجود y بزنید. اگر رد شوند یا معتبر نباشند، رمز ZIP در Prompt درخواست می‌شود. استخراج در پوشه موقت امن انجام می‌شود؛ فقط پس از اعتبارسنجی، فایل‌های Home جایگزین می‌شوند. نسخه قبلی در فایل‌های خصوصی پشتیبان نگهداری می‌شود. رمز اشتباه موجب توقف می‌شود؛ دستور را دوباره اجرا کنید. از ثبت خروجی کلید خصوصی در لاگ یا ارسال آن خودداری کنید.

<a name="install"></a>
## ۳. نصب Linux
```bash
curl -fsSL https://raw.githubusercontent.com/sina1991/How-to/main/SSH-Infrastructure-30nA/install.sh | bash
```
فقط کلیدهای استخراج‌شده را نصب می‌کند؛ هیچ ZIP یا Password دریافت نمی‌کند. مقصد ~/.ssh/id_ed25519 و ~/.ssh/id_ed25519.pub است. کلید متفاوت موجود در این مسیر بازنویسی نمی‌شود. کلید بدون Passphrase برای اتصال غیرتعاملی لازم است؛ اسکریپت Passphrase را حذف نمی‌کند. Permission خصوصی 600، عمومی 644 و پوشه 700 است. نصب باید با root انجام شود. OpenSSH Server نیز نصب می‌شود، Public Key به authorized_keys افزوده می‌شود و ورود root با Password و Public Key هم‌زمان فعال می‌شود. تنظیمات sshd پیش از reload اعتبارسنجی و نسخه پشتیبان تهیه می‌شود. Tunnelها مستقیماً تغییر نمی‌کنند. Match blockهای خاص ممکن است تنظیمات اتصال خارجی را تغییر دهند؛ اتصال واقعی را از نشست جداگانه آزمایش کنید.

<a name="connect"></a>
## ۴. اتصال به VPS
از Windows برای تست ورود به سرور ایران:
```powershell
ssh -o BatchMode=yes root@i.30na.top
```
برای تست Password:
```powershell
ssh -o PubkeyAuthentication=no -o PreferredAuthentications=password root@i.30na.top
```

```bash
ssh root@gr02.30na.top
```
برای Doprax هنگام ساخت VPS همان Public Key را انتخاب کنید. در اولین اتصال Fingerprint سرور را با Console معتبر تطبیق دهید. پس از آن برای تست بدون Password:
```bash
ssh -o BatchMode=yes root@gr02.30na.top true
```

<a name="password"></a>
## ۵. VPS دارای Password
```bash
ssh-copy-id -i ~/.ssh/id_ed25519.pub root@VPS_IP
```
IP واقعی را جایگزین کنید، هویت سرور را بررسی و Password مقصد را وارد کنید. سپس با ssh root@VPS_IP متصل شوید. اگر کاربر مقصد ubuntu است، نام کاربری را تغییر دهید.

<a name="security"></a>
## ۶. امنیت و خطاها
- ZIP not found: فایل را در Home بگذارید.
- Key pair mismatch: دوباره unzip.sh را اجرا کنید.
- Existing standard key differs: نصب متوقف می‌شود؛ کلید قدیمی را بدون بررسی حذف نکنید.
- Host key changed: از Console معتبر هویت جدید را بررسی کنید؛ اعتبارسنجی را غیرفعال نکنید.
- Permission denied: کاربر و authorized_keys مقصد را بررسی کنید.
- کلید خصوصی مشترک روی هر VPS مبدأ، ریسک دسترسی به همه مقصدها را ایجاد می‌کند. ZIP و رمز را در GitHub قرار ندهید. رمزهای قبلاً افشاشده را تغییر دهید.
- نسخه v7 هنوز روی VPS واقعی تست نشده است.

<a name="windows"></a>
## ۷. Windows
روی کامپیوتر مورد اعتماد ZIP را در Downloads قرار دهید. نصب‌کننده Windows قبلی مستقل است و OpenSSH و 7-Zip را در صورت نیاز نصب می‌کند؛ برای نصب خودکار 7-Zip به winget نیاز دارد. در PowerShell:
```powershell
clear; $p = Join-Path $env:TEMP "30na-install.ps1"; Invoke-WebRequest "https://raw.githubusercontent.com/sina1991/How-to/main/SSH-Infrastructure-30nA/install.ps1" -OutFile $p -ErrorAction Stop; powershell.exe -NoProfile -ExecutionPolicy Bypass -File $p
```
مسیر ZIP را تأیید و رمز را در Prompt وارد کنید. در صورت نیاز UAC را تأیید کنید. سپس ssh root@VPS_IP.

<a name="termius"></a>
## ۸. Termius
در Keychain همان Private Key را Import کنید، نه Generate Key. Host را با IP یا دامنه واقعی، پورت 22، کاربر مقصد و کلید واردشده تنظیم کنید. قبل از سفر دسترسی را آزمایش کنید.
