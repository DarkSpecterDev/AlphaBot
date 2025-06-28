#!/bin/bash
# NetBot Installation Script
# Network VPN Bot for Linux Servers
# Written By: NetworkBotDev

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[0;37m'
NC='\033[0m'

clear
echo -e "\n${BLUE}╔══════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║${NC}         ${GREEN}NetBot Installation${NC}         ${BLUE}║${NC}"
echo -e "${BLUE}║${NC}      ${CYAN}Network VPN Bot Manager${NC}       ${BLUE}║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════╝${NC}\n"
echo -e "    ${RED}Telegram Channel: ${BLUE}@NetworkBotChannel${NC} | ${RED}Support: ${BLUE}@NetworkBotSupport${NC}\n"

sleep 2
echo -e "${GREEN}Installing NetBot script ...${NC}\n"

if [[ $EUID -eq 0 ]]; then
   echo ""
else
   echo -e "${RED}This script must be run as root${NC}"
   exit 1
fi

# Update system
apt update -y && apt upgrade -y

# Install required packages
apt install -y curl wget unzip git nginx mysql-server php php-fpm php-mysql php-curl php-json php-mbstring

# Configure MySQL
mysql_secure_installation

# Configure Nginx
systemctl enable nginx
systemctl start nginx

# Configure PHP
systemctl enable php8.1-fpm
systemctl start php8.1-fpm

# Get domain name
read -p "Enter your domain name: " DOMAIN_NAME
read -p "Enter your bot token: " YOUR_BOT_TOKEN
read -p "Enter your admin chat ID: " YOUR_CHAT_ID

# Create database
echo "Creating database..."
randomdbpasstxt=$(openssl rand -base64 12)
ASAS='$'

# Setup database
mysql -u root -p -e "CREATE DATABASE IF NOT EXISTS netbot_db;"
mysql -u root -p -e "CREATE USER IF NOT EXISTS 'netbot_user'@'localhost' IDENTIFIED BY '${randomdbpasstxt}';"
mysql -u root -p -e "GRANT ALL PRIVILEGES ON netbot_db.* TO 'netbot_user'@'localhost';"
mysql -u root -p -e "FLUSH PRIVILEGES;"

# Clone NetBot repository
cd /var/www/html/
git clone https://github.com/DarkSpecterDev/AlphaBot.git netbot
sudo chown -R www-data:www-data /var/www/html/netbot/
sudo chmod -R 755 /var/www/html/netbot/

echo -e "\n${YELLOW}NetBot files have been installed successfully${NC}"

# Create baseInfo.php
cat > /var/www/html/netbot/baseInfo.php << EOF
<?php
error_reporting(0);
\$botToken = '${YOUR_BOT_TOKEN}';
\$dbUserName = 'netbot_user';
\$dbPassword = '${randomdbpasstxt}';
\$dbName = 'netbot_db';
\$botUrl = 'https://${DOMAIN_NAME}/netbot/';
\$admin = ${YOUR_CHAT_ID};
?>
EOF

# Set webhook
curl -F "url=https://${DOMAIN_NAME}/netbot/bot.php" "https://api.telegram.org/bot${YOUR_BOT_TOKEN}/setWebhook"

# Create database tables
curl "https://${DOMAIN_NAME}/netbot/createDB.php"

# Setup cron jobs
(crontab -l ; echo "* * * * * curl https://${DOMAIN_NAME}/netbot/settings/messagenetbot.php >/dev/null 2>&1") | sort - | uniq - | crontab -
(crontab -l ; echo "* * * * * curl https://${DOMAIN_NAME}/netbot/settings/rewardReport.php >/dev/null 2>&1") | sort - | uniq - | crontab -
(crontab -l ; echo "* * * * * curl https://${DOMAIN_NAME}/netbot/settings/warnusers.php >/dev/null 2>&1") | sort - | uniq - | crontab -

# Configure Nginx
cat > /etc/nginx/sites-available/netbot << EOF
server {
    listen 80;
    server_name ${DOMAIN_NAME};
    root /var/www/html/netbot;
    index index.php index.html;

    location / {
        try_files \$uri \$uri/ =404;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php8.1-fpm.sock;
    }
}
EOF

ln -s /etc/nginx/sites-available/netbot /etc/nginx/sites-enabled/
systemctl reload nginx

# Clean up installation files
rm -f /var/www/html/netbot/createDB.php
rm -f /var/www/html/netbot/install.sh
rm -f /var/www/html/netbot/netbot.sh

echo -e "\n${GREEN}╔══════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║${NC}     ${CYAN}NetBot Installation Complete!${NC}     ${GREEN}║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════╝${NC}\n"

echo -e "${BLUE}Bot URL:${NC} https://${DOMAIN_NAME}/netbot/"
echo -e "${BLUE}Database:${NC} netbot_db"
echo -e "${BLUE}DB User:${NC} netbot_user"
echo -e "${BLUE}DB Pass:${NC} ${randomdbpasstxt}"
echo -e "${BLUE}Admin ID:${NC} ${YOUR_CHAT_ID}"

echo -e "\n${YELLOW}Please test your bot in Telegram!${NC}"
echo -e "${GREEN}Installation completed successfully!${NC}\n"
