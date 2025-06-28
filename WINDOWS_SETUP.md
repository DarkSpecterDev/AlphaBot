# راهنمای نصب و راه‌اندازی آلفا ربات (AlphaBot) روی ویندوز

## ⚠️ توجه مهم
این ربات برای سرور لینوکس طراحی شده و بسیاری از امکانات آن روی ویندوز کار نخواهند کرد. فقط بخش‌های مربوط به رابط کاربری تلگرام قابل اجرا خواهند بود.

## پیش‌نیازها

### 1. نصب XAMPP
1. آخرین نسخه XAMPP را از [این لینک](https://sourceforge.net/projects/xampp/files/XAMPP%20Windows/8.2.12/xampp-windows-x64-8.2.12-0-VS16-installer.exe) دانلود کنید
2. XAMPP را با دسترسی Administrator نصب کنید
3. XAMPP Control Panel را اجرا کنید
4. سرویس‌های Apache و MySQL را Start کنید

### 2. ایجاد ربات تلگرام
1. به [@BotFather](https://t.me/BotFather) در تلگرام بروید
2. دستور `/newbot` را ارسال کنید
3. نام و username برای ربات انتخاب کنید
4. توکن ربات را کپی کنید (مثل: `1234567890:ABCdefGHIjklmNOPQrstuvWXYZ`)

### 3. دریافت آیدی عددی
1. به [@userinfobot](https://t.me/userinfobot) بروید
2. `/start` را ارسال کنید
3. آیدی عددی خود را کپی کنید

## مراحل نصب

### 1. کپی پروژه به XAMPP
پوشه `AlphaBot` را به مسیر زیر کپی کنید:
```
C:\xampp\htdocs\
```

### 2. ویرایش فایل تنظیمات
فایل `C:\xampp\htdocs\AlphaBot\baseInfo.php` را باز کرده و مقادیر زیر را تنظیم کنید:

```php
<?php
// تنظیمات دیتابیس
$dbUserName = "root";      // نام کاربری دیتابیس XAMPP
$dbPassword = "";          // رمز عبور دیتابیس XAMPP (معمولاً خالی)
$dbName = "alphabot_db";    // نام دیتابیس

// توکن ربات تلگرام شما
$botToken = "YOUR_BOT_TOKEN_HERE"; // توکن دریافتی از BotFather

// آیدی عددی ادمین
$admin = 123456789; // آیدی عددی دریافتی از userinfobot

// آدرس
$botUrl = "http://localhost/AlphaBot/";
?>
```

### 3. ایجاد دیتابیس
1. مرورگر را باز کنید و به آدرس زیر بروید:
   ```
   http://localhost/phpmyadmin
   ```
2. روی دکمه "New" یا "جدید" کلیک کنید
3. نام دیتابیس را `alphabot_db` وارد کنید
4. Collation را `utf8mb4_general_ci` انتخاب کنید
5. دکمه "Create" را بزنید

### 4. ایجاد جداول دیتابیس
در مرورگر به آدرس زیر بروید:
```
http://localhost/AlphaBot/createDB.php
```
اگر صفحه سفید نمایش داده شد، یعنی جداول با موفقیت ایجاد شدند.

### 5. تنظیم Webhook تلگرام
یک فایل جدید به نام `setWebhook.php` در پوشه پروژه ایجاد کنید:

```php
<?php
include_once 'baseInfo.php';

// برای استفاده از ngrok یا سرویس مشابه
$webhookUrl = "https://YOUR_NGROK_URL.ngrok.io/AlphaBot/bot.php";

$url = "https://api.telegram.org/bot" . $botToken . "/setWebhook?url=" . $webhookUrl;

$result = file_get_contents($url);
echo $result;
?>
```

### 6. استفاده از ngrok (برای تست محلی)
1. ngrok را از [ngrok.com](https://ngrok.com) دانلود کنید
2. در Command Prompt اجرا کنید:
   ```
   ngrok http 80
   ```
3. آدرس HTTPS تولید شده را در فایل `setWebhook.php` جایگزین کنید

### 7. اجرای setWebhook
در مرورگر به آدرس زیر بروید:
```
http://localhost/AlphaBot/setWebhook.php
```

## تست ربات
1. به ربات خود در تلگرام بروید
2. دستور `/start` را ارسال کنید
3. اگر پاسخ دریافت کردید، ربات با موفقیت راه‌اندازی شده است

## محدودیت‌ها در ویندوز

### امکاناتی که کار نخواهند کرد:
- ❌ اتصال به پنل‌های x-ui
- ❌ ایجاد و مدیریت کانفیگ‌های VPN
- ❌ بکاپ‌گیری خودکار
- ❌ اسکریپت‌های bash
- ❌ ارتباط با سرورهای VPS

### امکاناتی که کار خواهند کرد:
- ✅ رابط کاربری تلگرام
- ✅ مدیریت کاربران
- ✅ سیستم پرداخت (با تنظیمات اضافی)
- ✅ پایگاه داده محلی

## رفع مشکلات رایج

### 1. خطای اتصال به دیتابیس
- مطمئن شوید MySQL در XAMPP فعال است
- نام کاربری و رمز عبور را بررسی کنید

### 2. ربات پاسخ نمی‌دهد
- توکن ربات را بررسی کنید
- مطمئن شوید webhook درست تنظیم شده
- لاگ‌های Apache را در `C:\xampp\apache\logs\error.log` بررسی کنید

### 3. خطای PHP
- مطمئن شوید نسخه PHP حداقل 7.4 است
- افزونه‌های مورد نیاز PHP را در XAMPP فعال کنید:
  - curl
  - mysqli
  - mbstring
  - json

## توصیه نهایی
برای استفاده کامل از امکانات این ربات، توصیه می‌شود از یک سرور لینوکس (VPS) استفاده کنید. ویندوز فقط برای تست و توسعه محلی مناسب است. 