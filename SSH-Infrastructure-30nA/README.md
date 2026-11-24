<h1 align="center">SSH Infrastructure — 30nA</h1>
<p align="center"><strong>ONE KEY • ALL SERVERS • WINDOWS / LINUX / TERMIUS</strong></p>
<p align="center"><img alt="Version 3" src="https://img.shields.io/badge/Version-3-blue"> <img alt="ED25519" src="https://img.shields.io/badge/SSH-ED25519-green"> <img alt="AES256" src="https://img.shields.io/badge/Backup-AES256-orange"></p>

<div dir="rtl" align="right">

یک کلید مشترک برای تمام حساب‌های VPS، سرورهای جدید و دستگاه‌های مدیریتی مورد اعتماد. این دفترچه برای استفاده روزمره و بازیابی در سفر است.

</div>

## فهرست مطالب / Contents

| بخش | کاربرد |
|---|---|
| [01 — ساخت ZIP](#backup) | ساخت و تست نسخه پشتیبان |
| [02 — Windows](#windows) | نصب کلید در PowerShell |
| [03 — Linux](#linux) | نصب کلید در Ubuntu / Debian |
| [04 — Termius](#termius) | اتصال از موبایل یا دسکتاپ |
| [05 — VPS](#vps) | ثبت کلید در حساب جدید یا VPS موجود |
| [06 — عیب‌یابی](#help) | خطاها، امنیت و بازیابی |

---

<a name="backup"></a>
## 🟧 01 — ساخت ZIP / Backup

<div dir="rtl" align="right">

**محیط اجرا: PowerShell کامپیوتر اصلی.** فقط یک بار برای ساخت نسخه پشتیبان از کلید موجود. اسکریپت در صورت نیاز 7-Zip را نصب می‌کند، رمز را از شما می‌پرسد و آرشیو را تست می‌کند. کلید جدید تولید نمی‌شود.

</div>

```powershell
clear; $p = Join-Path $env:TEMP "30na-backup.ps1"; Invoke-WebRequest "https://raw.githubusercontent.com/sina1991/How-to/main/SSH-Infrastructure-30nA/backup.ps1" -OutFile $p -ErrorAction Stop; powershell.exe -NoProfile -ExecutionPolicy Bypass -File $p
```

**Output:** %USERPROFILE%\Downloads\30na-SSH-Backup.zip

<div dir="rtl" align="right">

رمز طولانی و تصادفی انتخاب کنید. فایل ZIP را در حافظه رمزگذاری‌شده یا محل امن نگهداری کنید؛ هیچ‌گاه در GitHub قرار ندهید. پیام Backup verified به معنای موفقیت تست آرشیو است.

</div>

---

<a name="windows"></a>
## 🟦 02 — Windows / PowerShell

<div dir="rtl" align="right">

**محیط اجرا: PowerShell عادی در کامپیوتر مورد اعتماد.** فایل ZIP را در Downloads، Home یا پوشه فعلی قرار دهید. دستور زیر را یکجا اجرا کنید. نصب‌کننده OpenSSH و 7-Zip را در صورت نیاز نصب و SSH Agent را فعال می‌کند. درخواست UAC را در صورت نیاز تأیید کنید. Windows Package Manager برای نصب خودکار 7-Zip لازم است.

</div>

```powershell
clear; $p = Join-Path $env:TEMP "30na-install.ps1"; Invoke-WebRequest "https://raw.githubusercontent.com/sina1991/How-to/main/SSH-Infrastructure-30nA/install.ps1" -OutFile $p -ErrorAction Stop; powershell.exe -NoProfile -ExecutionPolicy Bypass -File $p
```

<div dir="rtl" align="right">

در پیام ZIP path اگر مسیر درست است Enter بزنید؛ در پیام Enter password رمز ZIP را وارد کنید. اگر کلید Passphrase دارد، آن را نیز وارد کنید. پس از پیام موفقیت، برای اتصال IP یا دامنه واقعی سرور را جایگزین کنید.

</div>

```powershell
ssh root@VPS_IP
```

---

<a name="linux"></a>
## 🟩 03 — Ubuntu / Debian

<div dir="rtl" align="right">

**محیط اجرا: Bash در Linux، با حساب کاربری که قرار است از SSH استفاده کند.** ZIP را در پوشه فعلی، Home یا Downloads قرار دهید. دستور زیر curl را در صورت نیاز نصب می‌کند؛ نصب‌کننده نیز OpenSSH و 7-Zip را خودکار نصب می‌کند. برای نصب بسته‌ها دسترسی root یا sudo لازم است.

</div>

```bash
clear; if ! command -v curl >/dev/null; then if [ "$(id -u)" = 0 ]; then apt-get update && apt-get install -y curl; else sudo apt-get update && sudo apt-get install -y curl; fi; fi && f=$(mktemp) && curl -fsSL https://raw.githubusercontent.com/sina1991/How-to/main/SSH-Infrastructure-30nA/install.sh -o "$f" && bash "$f" && eval "$(ssh-agent -s)" && ssh-add ~/.ssh/30na_windows
```

<div dir="rtl" align="right">

در ZIP path مسیر فایل را وارد کنید یا Enter بزنید. سپس رمز ZIP را وارد کنید. پس از Key restored successfully و Identity added اتصال آماده است.

</div>

```bash
ssh root@VPS_IP
```

<div dir="rtl" align="right">

در نشست جدید ممکن است Agent قبلی در دسترس نباشد. در آن صورت از ssh -i ~/.ssh/30na_windows root@VPS_IP استفاده کنید. نصب کلید هیچ سرویس SSH یا Tunnel موجود را تغییر نمی‌دهد.

</div>

---

<a name="termius"></a>
## 🟪 04 — Termius

<div dir="rtl" align="right">

در موبایل یا کامپیوتر شخصی، از Keychain گزینه Import Key را انتخاب کنید و همان فایل خصوصی 30na_windows را از Backup امن وارد کنید؛ Generate Key نزنید. سپس Host جدید با IP یا دامنه واقعی، پورت 22، نام کاربری root و همان Key بسازید. Password سرور لازم نیست. اگر ارائه‌دهنده کاربر ubuntu دارد همان را انتخاب کنید. ورود به حساب Termius به تنهایی تضمین بازیابی کلید نیست؛ Sync را قبل از سفر آزمایش کنید.

</div>

[Download Termius](https://termius.com/download)

---

<a name="vps"></a>
## 🟦 05 — VPS / Doprax / Other providers

<div dir="rtl" align="right">

در Windows با دستور زیر Public Key را کپی کنید و در قسمت SSH Keys هر حساب ارائه‌دهنده با نام 30na-windows-admin ثبت کنید. هنگام ساخت VPS همان کلید را انتخاب کنید. در این صورت اگر کلید برای کاربر مقصد نصب شود نیازی به ssh-copy-id نیست.

</div>

```powershell
clear; Get-Content "$env:USERPROFILE\.ssh\30na_windows.pub" | Set-Clipboard
```

[Doprax SSH Keys](https://www.doprax.com/v/services/virtual-machines/ssh-keys/)

<div dir="rtl" align="right">

برای VPS موجود بدون کلید، فایل عمومی را از راه امن به Home کاربر مقصد منتقل کنید و در Console معتبر همان کاربر دستور زیر را اجرا کنید. کلیدهای قدیمی حفظ می‌شوند.

</div>

```bash
clear; f=$(mktemp) && curl -fsSL https://raw.githubusercontent.com/sina1991/How-to/main/SSH-Infrastructure-30nA/install-public-key.sh -o "$f" && bash "$f" "$HOME/30na_windows.pub"
```

---

<a name="help"></a>
## 🟥 06 — Troubleshooting & Security

| Message | راه حل |
|---|---|
| ZIP not found | مسیر فایل را وارد کنید، نه رمز |
| Wrong password | رمز واقعی آرشیو را وارد کنید |
| Existing key differs | فایل قبلی را حذف نکنید؛ Fingerprint را بررسی کنید |
| Permission denied (publickey) | کلید عمومی و نام کاربری مقصد را بررسی کنید |
| Host key changed | هویت سرور جدید را از Console معتبر بررسی کنید |

<div dir="rtl" align="right">

برای بررسی Host Key در Console معتبر سرور از دستور زیر استفاده کنید؛ تنها پس از تطبیق کامل آن را در کلاینت تأیید کنید.

</div>

```bash
ssh-keygen -lf /etc/ssh/ssh_host_ed25519_key.pub
```

> [!IMPORTANT]
> یک Private Key مشترک یعنی افشای آن می‌تواند همه VPSها را در معرض خطر قرار دهد. روی کامپیوتر عمومی از Termius موبایل شخصی استفاده کنید. ZIP و رمز را در مخزن قرار ندهید. اگر کلید افشا شد، در تمام حساب‌ها و سرورها آن را تعویض کنید. حذف کلید از پنل لزوماً کلید نصب‌شده روی VPS موجود را حذف نمی‌کند.

<div dir="rtl" align="right">

**وضعیت تست:** بازیابی V2 در Windows و Ubuntu و اتصال Linux به VPS با گزارش مالک موفق بوده است. V3 همان منطق بازیابی را حفظ می‌کند و نصب پیش‌نیازها را اضافه کرده است؛ مسیر نصب خودکار پیش‌نیازها هنوز نیاز به تست روی سیستم تازه دارد. سرور ایران و Tunnelهای فعال تغییر نکرده‌اند.

</div>
