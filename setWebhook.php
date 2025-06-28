<?php
include_once 'baseInfo.php';

// برای استفاده محلی با ngrok
// آدرس ngrok فعلی - ربات اصلی (IP check غیرفعال)
$webhookUrl = "https://28f9-213-142-150-127.ngrok-free.app/AlphaBot/bot.php";

// برای استفاده روی سرور واقعی
// $webhookUrl = "https://28f9-213-142-150-127.ngrok-free.app/AlphaBot/bot.php";

$url = "https://api.telegram.org/bot" . $botToken . "/setWebhook?url=" . $webhookUrl;

$result = file_get_contents($url);
$response = json_decode($result, true);

if($response['ok'] == true) {
    echo "<h2>✅ Webhook با موفقیت تنظیم شد!</h2>";
    echo "<p>توضیحات: " . $response['description'] . "</p>";
} else {
    echo "<h2>❌ خطا در تنظیم Webhook</h2>";
    echo "<p>پیام خطا: " . $response['description'] . "</p>";
}

echo "<hr>";
echo "<h3>اطلاعات Webhook فعلی:</h3>";

// دریافت اطلاعات webhook فعلی
$infoUrl = "https://api.telegram.org/bot" . $botToken . "/getWebhookInfo";
$info = json_decode(file_get_contents($infoUrl), true);

echo "<pre>";
print_r($info);
echo "</pre>";
?> 