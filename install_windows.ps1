# اسکریپت نصب آلفا ربات (AlphaBot) روی ویندوز
# این اسکریپت را با PowerShell Admin اجرا کنید

Write-Host "==================================" -ForegroundColor Cyan
Write-Host "نصب آلفا ربات (AlphaBot) روی ویندوز" -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan

# بررسی وجود XAMPP
$xamppPath = "C:\xampp"
if (-Not (Test-Path $xamppPath)) {
    Write-Host "❌ XAMPP یافت نشد!" -ForegroundColor Red
    Write-Host "لطفا ابتدا XAMPP را نصب کنید" -ForegroundColor Yellow
    Write-Host "دانلود از: https://www.apachefriends.org/download.html" -ForegroundColor Yellow
    exit
}

Write-Host "✅ XAMPP یافت شد" -ForegroundColor Green

# بررسی مسیر htdocs
$htdocsPath = "$xamppPath\htdocs"
if (-Not (Test-Path $htdocsPath)) {
    Write-Host "❌ پوشه htdocs یافت نشد!" -ForegroundColor Red
    exit
}

# بررسی مسیر پروژه
$projectPath = Get-Location
$projectName = Split-Path $projectPath -Leaf

if ($projectName -ne "AlphaBot") {
    Write-Host "❌ لطفا این اسکریپت را از داخل پوشه AlphaBot اجرا کنید" -ForegroundColor Red
    exit
}

# کپی پروژه به htdocs
$targetPath = "$htdocsPath\AlphaBot"
Write-Host "در حال کپی پروژه به $targetPath ..." -ForegroundColor Yellow

if (Test-Path $targetPath) {
    $confirm = Read-Host "پوشه از قبل وجود دارد. آیا می‌خواهید جایگزین شود؟ (Y/N)"
    if ($confirm -eq 'Y' -or $confirm -eq 'y') {
        Remove-Item $targetPath -Recurse -Force
    } else {
        Write-Host "عملیات لغو شد" -ForegroundColor Red
        exit
    }
}

Copy-Item -Path $projectPath -Destination $htdocsPath -Recurse
Write-Host "✅ پروژه کپی شد" -ForegroundColor Green

# اجرای Apache و MySQL
Write-Host "در حال راه‌اندازی سرویس‌ها..." -ForegroundColor Yellow
Start-Process "$xamppPath\xampp-control.exe"

Write-Host "`n==================================" -ForegroundColor Cyan
Write-Host "مراحل بعدی:" -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan
Write-Host "1. در XAMPP Control Panel، Apache و MySQL را Start کنید" -ForegroundColor White
Write-Host "2. فایل baseInfo.php را ویرایش کرده و اطلاعات ربات را وارد کنید" -ForegroundColor White
Write-Host "3. در مرورگر به http://localhost/phpmyadmin بروید" -ForegroundColor White
Write-Host "4. دیتابیس alphabot_db را ایجاد کنید" -ForegroundColor White
Write-Host "5. به http://localhost/AlphaBot/createDB.php بروید" -ForegroundColor White
Write-Host "6. ngrok را دانلود و اجرا کنید: ngrok http 80" -ForegroundColor White
Write-Host "7. آدرس ngrok را در setWebhook.php وارد کنید" -ForegroundColor White
Write-Host "8. به http://localhost/AlphaBot/setWebhook.php بروید" -ForegroundColor White

Write-Host "`nبرای مشاهده راهنمای کامل، فایل WINDOWS_SETUP.md را بخوانید" -ForegroundColor Yellow 