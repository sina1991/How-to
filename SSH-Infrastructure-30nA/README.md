# 30nA — SSH Local Setup

یک کلید مشترک موجود، بدون تولید کلید جدید، بدون وابستگی به SSH Agent و بدون درخواست رمز ZIP در نصب‌کننده Linux.

## فهرست

- [۱. استخراج دستی](#extract)
- [۲. نصب Linux](#linux)
- [۳. اتصال به VPS](#connect)
- [۴. VPS دارای Password](#password)
- [۵. Windows و Termius](#windows)

<a name="extract"></a>
## 🟧 ۱. استخراج دستی ZIP (Ubuntu/Debian)

فایل 30na-SSH-Backup.zip را در Home کاربر قرار دهید. ابزار unzip معمولی از AES ZIP پشتیبانی نمی‌کند. با کاربر root دستور زیر را اجرا و رمز را فقط در Prompt وارد کنید.

```bash
clear; apt-get update && apt-get install -y p7zip-full && (umask 077; 7z x "$HOME/30na-SSH-Backup.zip" -aos -o"$HOME" && chmod 600 "$HOME/30na_windows" && chmod 644 "$HOME/30na_windows.pub")
```

دو فایل مورد انتظار: 30na_windows و 30na_windows.pub. برای کاربر غیر root، apt-get را با sudo اجرا کنید.

<a name="linux"></a>
## 🟩 ۲. نصب Linux — یک دستور

روی سرور مبدأ با همان کاربری که اتصال SSH را برقرار می‌کند اجرا کنید. نصب‌کننده پیش‌نیازها را در صورت نبود نصب می‌کند، کلید استخراج‌شده را بررسی می‌کند، Public Key و Fingerprint را نمایش می‌دهد و کلید خصوصی را محرمانه نگه می‌دارد. کلیدها در مسیر استاندارد id_ed25519 نصب می‌شوند؛ کلید متفاوت موجود بازنویسی نمی‌شود. رمز ZIP درخواست نمی‌شود.

```bash
clear; if ! command -v curl >/dev/null; then if [ "$(id -u)" = 0 ]; then apt-get update && apt-get install -y curl; else sudo apt-get update && sudo apt-get install -y curl; fi; fi && f=$(mktemp) && curl -fsSL https://raw.githubusercontent.com/sina1991/How-to/main/SSH-Infrastructure-30nA/install.sh -o "$f" && bash "$f"
```

کلید خصوصی باید برای اتصال غیرتعاملی بدون Passphrase باشد؛ نصب‌کننده Passphrase را حذف نمی‌کند. اگر کلید محافظت‌شده است متوقف می‌شود. هیچ فایل authorized_keys یا known_hosts و هیچ سرویس یا Tunnel تغییر نمی‌کند. در صورت استفاده از یک کلید مشترک روی VPS، نفوذ به آن VPS می‌تواند تمام مقصدها را در معرض خطر قرار دهد.

<a name="connect"></a>
## 🟦 ۳. اتصال به VPS دارای Public Key

```bash
ssh root@VPS_IP
```

در اولین اتصال، Host Key را با Console معتبر سرویس‌دهنده تطبیق دهید. برای Doprax که Public Key از قبل نصب شده، ssh-copy-id لازم نیست. برای تست غیرتعاملی از ssh -o BatchMode=yes root@VPS_IP true استفاده کنید (پس از تأیید Host Key).

<a name="password"></a>
## 🟪 ۴. VPS جدید دارای Password

از سرور مبدأ اجرا کنید:

```bash
ssh-copy-id -i ~/.ssh/id_ed25519.pub root@VPS_IP
```

پس از بررسی Host Key، Password سرور مقصد را وارد کنید. سپس با ssh root@VPS_IP متصل شوید. اگر مقصد کاربر ubuntu دارد، root را با ubuntu جایگزین کنید.

<a name="windows"></a>
## Windows و Termius

در Windows و Termius قبلاً همان کلید مشترک قابل استفاده بوده است. در این بازنویسی تمرکز روی Linux است؛ نصب‌کننده Windows قبلی برای بازیابی ZIP مستقل باقی مانده است.

```powershell
clear; $p = Join-Path $env:TEMP "30na-install.ps1"; Invoke-WebRequest "https://raw.githubusercontent.com/sina1991/How-to/main/SSH-Infrastructure-30nA/install.ps1" -OutFile $p -ErrorAction Stop; powershell.exe -NoProfile -ExecutionPolicy Bypass -File $p
```

در Termius همان Private Key را Import کنید. کلید و ZIP را در GitHub قرار ندهید. رمزهای افشاشده را تعویض کنید.

**وضعیت:** نصب Linux v4 از فایل استخراج‌شده هنوز روی VPS واقعی تست نشده است.
