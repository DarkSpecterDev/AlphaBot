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
apt install -y php8.1 php8.1-fpm php8.1-mysql php8.1-curl php8.1-mbstring php8.1-xml php8.1-zip php8.1-gd php8.1-cli php8.1-common

# Install MySQL with low memory configuration
echo -e "${YELLOW}Installing MySQL...${NC}"

# Pre-configure MySQL to avoid interactive prompts
export DEBIAN_FRONTEND=noninteractive
debconf-set-selections <<< "mysql-server mysql-server/root_password password rootpass"
debconf-set-selections <<< "mysql-server mysql-server/root_password_again password rootpass"

# Create MySQL configuration for low memory before installation
mkdir -p /etc/mysql/mysql.conf.d
cat > /etc/mysql/mysql.conf.d/low-memory.cnf << EOF
[mysqld]
# Low memory configuration
innodb_buffer_pool_size = 64M
innodb_log_file_size = 16M
innodb_log_buffer_size = 4M
key_buffer_size = 16M
table_open_cache = 64
sort_buffer_size = 512K
read_buffer_size = 256K
read_rnd_buffer_size = 512K
myisam_sort_buffer_size = 8M
thread_cache_size = 8
query_cache_size = 16M
tmp_table_size = 16M
max_heap_table_size = 16M
max_connections = 50
thread_stack = 192K
bulk_insert_buffer_size = 8M
myisam_sort_buffer_size = 8M
myisam_max_sort_file_size = 1G
myisam_repair_threads = 1

# Disable performance schema to save memory
performance_schema = OFF

# InnoDB settings for low memory
innodb_flush_method = O_DIRECT
innodb_flush_log_at_trx_commit = 2
innodb_file_per_table = 1
innodb_open_files = 300
EOF

# Install MySQL
apt install -y mysql-server

# Configure MySQL
echo -e "${YELLOW}Configuring MySQL...${NC}"
systemctl start mysql
systemctl enable mysql

# Wait for MySQL to start
sleep 10

# Secure MySQL installation
mysql -u root -prootpass -e "
DELETE FROM mysql.user WHERE User='';
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
FLUSH PRIVILEGES;
" 2>/dev/null || echo "MySQL security configuration completed"

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

# Check if services are running
if systemctl is-active --quiet mysql; then
    echo -e "${GREEN}✅ MySQL: Running${NC}"
else
    echo -e "${RED}❌ MySQL: Failed${NC}"
fi

if systemctl is-active --quiet nginx; then
    echo -e "${GREEN}✅ Nginx: Running${NC}"
else
    echo -e "${RED}❌ Nginx: Failed${NC}"
fi

if systemctl is-active --quiet php8.1-fpm; then
    echo -e "${GREEN}✅ PHP-FPM: Running${NC}"
else
    echo -e "${RED}❌ PHP-FPM: Failed${NC}"
fi

# Display system info
echo -e "\n${YELLOW}System Information:${NC}"
echo -e "MySQL Version: $(mysql --version 2>/dev/null | cut -d' ' -f3 || echo 'Not available')"
echo -e "PHP Version: $(php -v 2>/dev/null | head -n1 | cut -d' ' -f2 || echo 'Not available')"
echo -e "Nginx Version: $(nginx -v 2>&1 | cut -d' ' -f3 | cut -d'/' -f2 || echo 'Not available')"

# Display memory usage
echo -e "\n${YELLOW}Memory Usage:${NC}"
free -h 2>/dev/null | head -n2 || echo "Memory info not available"

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

echo -e "\n${YELLOW}Troubleshooting:${NC}"
echo -e "If you encounter MySQL OOM errors or installation issues, run:"
echo -e "${BLUE}wget -O fix_install.sh https://raw.githubusercontent.com/DarkSpecterDev/AlphaBot/main/fix_install.sh${NC}"
echo -e "${BLUE}chmod +x fix_install.sh && sudo ./fix_install.sh${NC}"
echo -e "2. Test your bot by sending /start in Telegram"
echo -e "3. Check logs if needed: ${YELLOW}tail -f /var/log/nginx/error.log${NC}"
