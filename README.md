# 🤖 آلفا ربات (AlphaBot)

<p align="center">
  <img src="assets/logo.png" alt="AlphaBot Logo" width="200"/>
</p>

<h1 align="center">آلفا ربات - ربات فروش VPN حرفه‌ای</h1>

<p align="center">
فروش آسان و مدیریت پنل‌های VPN با آلفا ربات (AlphaBot)
</p>

<p align="center">
  <img src="https://img.shields.io/github/license/DarkSpecterDev/AlphaBot?style=flat-square" />
  <img src="https://img.shields.io/github/v/release/DarkSpecterDev/AlphaBot.svg" />
  <img src="https://img.shields.io/badge/PHP-7.4+-blue.svg" />
  <img src="https://img.shields.io/badge/Platform-Windows%20%7C%20Linux-lightgrey.svg" />
</p>

## 📋 ویژگی‌های اصلی

- 🔐 **پشتیبانی از پنل‌های مختلف**: x-ui, 3x-ui, Marzban و سایر پنل‌ها
- 💳 **درگاه‌های پرداخت متنوع**: ZarinPal، NextPay، NowPayment، Tron و کارت به کارت
- 👥 **سیستم نمایندگی**: امکان تعریف نماینده با درصد تخفیف
- 📊 **گزارش‌گیری کامل**: آمار فروش، درآمد و کاربران
- 🎁 **سیستم هدیه**: ارسال اکانت رایگان برای کاربران جدید
- 🔒 **امنیت بالا**: سیستم احراز هویت و کنترل دسترسی
- 📱 **رابط کاربری زیبا**: طراحی مدرن و کاربرپسند
- 🌐 **چندزبانه**: پشتیبانی از فارسی و انگلیسی

## 🚀 نصب سریع

### نصب روی لینوکس (Ubuntu/Debian)

```bash
bash <(curl -s https://raw.githubusercontent.com/DarkSpecterDev/AlphaBot/main/install.sh)
```

### نصب روی ویندوز

1. **نصب XAMPP**:
   - [دانلود XAMPP](https://www.apachefriends.org/download.html)
   - نصب و راه‌اندازی Apache و MySQL

2. **دانلود پروژه**:
   ```bash
   git clone https://github.com/DarkSpecterDev/AlphaBot.git
   ```

3. **کپی به XAMPP**:
   ```
   C:\xampp\htdocs\AlphaBot\
   ```

4. **تنظیمات**:
   - ویرایش فایل `baseInfo.php`
   - ایجاد دیتابیس `alphabot_db`
   - اجرای `createDB.php`

📖 **راهنمای کامل**: [WINDOWS_SETUP.md](WINDOWS_SETUP.md)

## ⚙️ تنظیمات اولیه

### 1. ایجاد ربات تلگرام
- به [@BotFather](https://t.me/BotFather) بروید
- دستور `/newbot` را ارسال کنید
- توکن ربات را دریافت کنید

### 2. تنظیم فایل baseInfo.php
```php
<?php
$dbUserName = "root";
$dbPassword = "";
$dbName = "alphabot_db";
$botToken = "YOUR_BOT_TOKEN";
$admin = YOUR_CHAT_ID;
$botUrl = "https://yourdomain.com/AlphaBot/";
?>
```

### 3. تنظیم Webhook
```
https://yourdomain.com/AlphaBot/setWebhook.php
```

## 📱 ویژگی‌های ربات

- ✅ **فروش خودکار**: خرید و فعال‌سازی خودکار اکانت‌ها
- 💰 **مدیریت کیف پول**: شارژ کیف پول و تراکنش‌ها
- 🎯 **تست اکانت**: ارائه اکانت تست رایگان
- 📈 **آمارگیری**: نمایش آمار کامل فروش
- 🔄 **تمدید اکانت**: تمدید آسان اکانت‌های موجود
- 📋 **مدیریت سرورها**: افزودن و مدیریت سرورهای مختلف
- 🎁 **کدهای تخفیف**: ایجاد و مدیریت کدهای تخفیف

## 🛠️ نیازمندی‌های سیستم

- **PHP**: 7.4 یا بالاتر
- **MySQL**: 5.7 یا بالاتر
- **cURL**: فعال
- **OpenSSL**: فعال
- **دسترسی به اینترنت**: برای اتصال به API تلگرام

## 📞 پشتیبانی

- 🐛 **گزارش باگ**: [Issues](https://github.com/DarkSpecterDev/AlphaBot/issues)
- 💬 **سوالات**: از بخش Discussions استفاده کنید
- 📧 **ایمیل**: برای موارد خاص

## 📄 مجوز

این پروژه تحت مجوز MIT منتشر شده است. برای اطلاعات بیشتر فایل [LICENSE](LICENSE) را مطالعه کنید.

## 🙏 تشکر

از تمام کسانی که در توسعه این پروژه مشارکت داشته‌اند تشکر می‌کنیم.

---

<p align="center">
  ساخته شده با ❤️ توسط DarkSpecterDev
</p>
