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

# Stop conflicting services
echo -e "${YELLOW}Stopping conflicting services...${NC}"
systemctl stop apache2 2>/dev/null
systemctl disable apache2 2>/dev/null
systemctl stop mysql 2>/dev/null

# Update system
echo -e "${YELLOW}Updating system packages...${NC}"
apt update -y && apt upgrade -y

# Remove Apache if installed
echo -e "${YELLOW}Removing Apache to avoid conflicts...${NC}"
apt remove apache2 apache2-utils -y 2>/dev/null

# Install required packages (without mysql-server for now)
echo -e "${YELLOW}Installing required packages...${NC}"
apt install -y curl wget unzip git nginx software-properties-common

# Add PHP repository
add-apt-repository ppa:ondrej/php -y
apt update

# Install PHP 8.1 (more stable)
echo -e "${YELLOW}Installing PHP 8.1...${NC}"
apt install -y php8.1 php8.1-fpm php8.1-mysql php8.1-curl php8.1-json php8.1-mbstring php8.1-xml php8.1-zip

# Install MySQL with proper configuration
echo -e "${YELLOW}Installing MySQL...${NC}"
export DEBIAN_FRONTEND=noninteractive
echo "mysql-server mysql-server/root_password password rootpass" | debconf-set-selections
echo "mysql-server mysql-server/root_password_again password rootpass" | debconf-set-selections
apt install -y mysql-server

# Configure MySQL
echo -e "${YELLOW}Configuring MySQL...${NC}"
systemctl start mysql
systemctl enable mysql

# Wait for MySQL to start
sleep 5

# Set MySQL root password
mysql -u root -prootpass -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'rootpass';" 2>/dev/null
mysql -u root -prootpass -e "FLUSH PRIVILEGES;" 2>/dev/null

# Configure Nginx
echo -e "${YELLOW}Configuring Nginx...${NC}"
systemctl enable nginx
systemctl start nginx

# Configure PHP
echo -e "${YELLOW}Configuring PHP...${NC}"
systemctl enable php8.1-fpm
systemctl start php8.1-fpm

# Get user input
echo -e "${CYAN}Please provide the following information:${NC}"
read -p "Enter your domain name: " DOMAIN_NAME
read -p "Enter your bot token: " YOUR_BOT_TOKEN
read -p "Enter your admin chat ID: " YOUR_CHAT_ID

# Create database
echo -e "${YELLOW}Creating database...${NC}"
randomdbpasstxt=$(openssl rand -base64 12)
ASAS='$'

# Setup database
mysql -u root -prootpass -e "CREATE DATABASE IF NOT EXISTS netbot_db;" 2>/dev/null
mysql -u root -prootpass -e "CREATE USER IF NOT EXISTS 'netbot_user'@'localhost' IDENTIFIED BY '${randomdbpasstxt}';" 2>/dev/null
mysql -u root -prootpass -e "GRANT ALL PRIVILEGES ON netbot_db.* TO 'netbot_user'@'localhost';" 2>/dev/null
mysql -u root -prootpass -e "FLUSH PRIVILEGES;" 2>/dev/null

# Clone NetBot repository
echo -e "${YELLOW}Downloading NetBot files...${NC}"
cd /var/www/html/
rm -rf netbot 2>/dev/null
git clone https://github.com/DarkSpecterDev/AlphaBot.git netbot
sudo chown -R www-data:www-data /var/www/html/netbot/
sudo chmod -R 755 /var/www/html/netbot/

echo -e "\n${YELLOW}NetBot files have been installed successfully${NC}"

# Create baseInfo.php
echo -e "${YELLOW}Creating configuration file...${NC}"
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

# Configure Nginx for NetBot
echo -e "${YELLOW}Configuring web server...${NC}"
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
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        include fastcgi_params;
    }

    location ~ /\.ht {
        deny all;
    }
}
EOF

# Enable the site
ln -s /etc/nginx/sites-available/netbot /etc/nginx/sites-enabled/ 2>/dev/null
rm /etc/nginx/sites-enabled/default 2>/dev/null
systemctl reload nginx

# Create database tables
echo -e "${YELLOW}Setting up database tables...${NC}"
curl -s "http://${DOMAIN_NAME}/netbot/createDB.php" >/dev/null 2>&1

# Set webhook
echo -e "${YELLOW}Setting up Telegram webhook...${NC}"
curl -s -F "url=https://${DOMAIN_NAME}/netbot/bot.php" "https://api.telegram.org/bot${YOUR_BOT_TOKEN}/setWebhook" >/dev/null 2>&1

# Setup cron jobs
echo -e "${YELLOW}Setting up scheduled tasks...${NC}"
(crontab -l 2>/dev/null; echo "* * * * * curl -s https://${DOMAIN_NAME}/netbot/settings/messagenetbot.php >/dev/null 2>&1") | crontab -
(crontab -l 2>/dev/null; echo "* * * * * curl -s https://${DOMAIN_NAME}/netbot/settings/rewardReport.php >/dev/null 2>&1") | crontab -
(crontab -l 2>/dev/null; echo "* * * * * curl -s https://${DOMAIN_NAME}/netbot/settings/warnusers.php >/dev/null 2>&1") | crontab -

# Clean up installation files
echo -e "${YELLOW}Cleaning up...${NC}"
rm -f /var/www/html/netbot/createDB.php
rm -f /var/www/html/netbot/install.sh
rm -f /var/www/html/netbot/netbot.sh

# Final status check
echo -e "${YELLOW}Checking services...${NC}"
systemctl status nginx --no-pager -l
systemctl status mysql --no-pager -l
systemctl status php8.1-fpm --no-pager -l

echo -e "\n${GREEN}╔══════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║${NC}     ${CYAN}NetBot Installation Complete!${NC}     ${GREEN}║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════╝${NC}\n"

echo -e "${BLUE}Bot URL:${NC} https://${DOMAIN_NAME}/netbot/"
echo -e "${BLUE}Database:${NC} netbot_db"
echo -e "${BLUE}DB User:${NC} netbot_user"
echo -e "${BLUE}DB Pass:${NC} ${randomdbpasstxt}"
echo -e "${BLUE}MySQL Root Pass:${NC} rootpass"
echo -e "${BLUE}Admin ID:${NC} ${YOUR_CHAT_ID}"

echo -e "\n${YELLOW}Please test your bot in Telegram!${NC}"
echo -e "${GREEN}Installation completed successfully!${NC}\n"

echo -e "${CYAN}Next steps:${NC}"
echo -e "1. Set up SSL certificate with: ${YELLOW}certbot --nginx -d ${DOMAIN_NAME}${NC}"
echo -e "2. Test your bot by sending /start in Telegram"
echo -e "3. Check logs if needed: ${YELLOW}tail -f /var/log/nginx/error.log${NC}"
