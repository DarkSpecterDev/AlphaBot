#!/bin/bash
# AlphaBot Installation Script
# Network VPN Bot for Linux Servers
# Written By: MrVyxen

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[0;37m'
BOLD='\033[1m'
DIM='\033[2m'
UNDERLINE='\033[4m'
BLINK='\033[5m'
NC='\033[0m'



clear

# Simple header without complex unicode
echo -e "${CYAN}================================================${NC}"
echo -e "${GREEN}         AlphaBot Installation Script          ${NC}"
echo -e "${GREEN}         Network VPN Bot Manager               ${NC}"
echo -e "${CYAN}================================================${NC}"
echo -e "${BLUE}Author: MrVyxen${NC}"
echo -e "${BLUE}GitHub: https://github.com/MrVyxen/AlphaBot${NC}"
echo -e "${CYAN}================================================${NC}"
echo ""

if [[ $EUID -eq 0 ]]; then
   echo ""
else
   echo -e "${RED}This script must be run as root${NC}"
   exit 1
fi

# Stop conflicting services
echo -e "${YELLOW}STEP 1: Stopping conflicting services...${NC}"
systemctl stop apache2 2>/dev/null
systemctl disable apache2 2>/dev/null
systemctl stop mysql 2>/dev/null
echo -e "${GREEN}Services stopped${NC}"
echo ""

# Update system
echo -e "${YELLOW}STEP 2: Updating system packages...${NC}"
apt update -y && apt upgrade -y
echo -e "${GREEN}System updated${NC}"
echo ""

# Remove Apache if installed
echo -e "${YELLOW}STEP 3: Removing Apache conflicts...${NC}"
apt remove apache2 apache2-utils -y 2>/dev/null
echo -e "${GREEN}Apache removed${NC}"
echo ""

# Install required packages
echo -e "${YELLOW}STEP 4: Installing required packages...${NC}"
apt install -y curl wget unzip git nginx software-properties-common
echo -e "${GREEN}Base packages installed${NC}"
echo ""

# Add PHP repository
echo -e "${YELLOW}STEP 5: Adding PHP repository...${NC}"
add-apt-repository ppa:ondrej/php -y
apt update
echo -e "${GREEN}PHP repository added${NC}"
echo ""

# Install PHP 8.1
echo -e "${YELLOW}STEP 6: Installing PHP 8.1...${NC}"
apt install -y php8.1 php8.1-fpm php8.1-mysql php8.1-curl php8.1-mbstring php8.1-xml php8.1-zip php8.1-gd php8.1-cli php8.1-common
echo -e "${GREEN}PHP 8.1 installed${NC}"
echo ""

# Install MySQL with low memory configuration
echo -e "${YELLOW}STEP 7: Installing MySQL...${NC}"

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
echo -e "${BLUE}Waiting for MySQL to initialize...${NC}"
sleep 10

# Secure MySQL installation
mysql -u root -prootpass -e "
DELETE FROM mysql.user WHERE User='';
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
FLUSH PRIVILEGES;
" 2>/dev/null

echo -e "${GREEN}MySQL installed and secured${NC}"
echo ""

# Configure Nginx
echo -e "${YELLOW}STEP 8: Configuring Nginx...${NC}"
systemctl enable nginx
systemctl start nginx
echo -e "${GREEN}Nginx configured${NC}"
echo ""

# Configure PHP
echo -e "${YELLOW}STEP 9: Configuring PHP-FPM...${NC}"
systemctl enable php8.1-fpm
systemctl start php8.1-fpm
echo -e "${GREEN}PHP-FPM configured${NC}"
echo ""

# Get user input
echo -e "${CYAN}================================================${NC}"
echo -e "${CYAN}           CONFIGURATION SETUP                  ${NC}"
echo -e "${CYAN}================================================${NC}"
echo ""

echo -e "${BLUE}Domain Configuration:${NC}"
read -p "Enter your domain name: " DOMAIN_NAME

echo ""
echo -e "${BLUE}Bot Configuration:${NC}"
read -p "Enter your bot token: " YOUR_BOT_TOKEN

echo ""
echo -e "${BLUE}Admin Configuration:${NC}"
read -p "Enter your admin chat ID: " YOUR_CHAT_ID

echo ""
echo -e "${GREEN}Configuration collected successfully!${NC}"
echo ""

# Create database
echo -e "${YELLOW}STEP 10: Creating database...${NC}"
randomdbpasstxt=$(openssl rand -base64 12)
ASAS='$'

# Setup database
mysql -u root -prootpass -e "CREATE DATABASE IF NOT EXISTS netbot_db;" 2>/dev/null
mysql -u root -prootpass -e "CREATE USER IF NOT EXISTS 'netbot_user'@'localhost' IDENTIFIED BY '${randomdbpasstxt}';" 2>/dev/null
mysql -u root -prootpass -e "GRANT ALL PRIVILEGES ON netbot_db.* TO 'netbot_user'@'localhost';" 2>/dev/null
mysql -u root -prootpass -e "FLUSH PRIVILEGES;" 2>/dev/null
echo -e "${GREEN}Database created successfully${NC}"
echo ""

# Clone AlphaBot repository
echo -e "${YELLOW}STEP 11: Downloading AlphaBot files...${NC}"
cd /var/www/html/
rm -rf netbot 2>/dev/null
git clone https://github.com/MrVyxen/AlphaBot.git netbot
sudo chown -R www-data:www-data /var/www/html/netbot/
sudo chmod -R 755 /var/www/html/netbot/
echo -e "${GREEN}AlphaBot files downloaded and configured${NC}"
echo ""

# Create baseInfo.php
echo -e "${YELLOW}STEP 12: Creating configuration file...${NC}"
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
echo -e "${GREEN}Configuration file created${NC}"
echo ""

# Configure Nginx for AlphaBot
echo -e "${YELLOW}STEP 13: Configuring web server...${NC}"
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
echo -e "${GREEN}Web server configured${NC}"
echo ""

# Create database tables
echo -e "${YELLOW}STEP 14: Setting up database tables...${NC}"
curl -s "http://${DOMAIN_NAME}/netbot/createDB.php" >/dev/null 2>&1
echo -e "${GREEN}Database tables created${NC}"
echo ""

# Set webhook
echo -e "${YELLOW}STEP 15: Setting up Telegram webhook...${NC}"
curl -s -F "url=https://${DOMAIN_NAME}/netbot/bot.php" "https://api.telegram.org/bot${YOUR_BOT_TOKEN}/setWebhook" >/dev/null 2>&1
echo -e "${GREEN}Telegram webhook configured${NC}"
echo ""

# Setup cron jobs
echo -e "${YELLOW}STEP 16: Setting up scheduled tasks...${NC}"
(crontab -l 2>/dev/null; echo "* * * * * curl -s https://${DOMAIN_NAME}/netbot/settings/messagenetbot.php >/dev/null 2>&1") | crontab -
(crontab -l 2>/dev/null; echo "* * * * * curl -s https://${DOMAIN_NAME}/netbot/settings/rewardReport.php >/dev/null 2>&1") | crontab -
(crontab -l 2>/dev/null; echo "* * * * * curl -s https://${DOMAIN_NAME}/netbot/settings/warnusers.php >/dev/null 2>&1") | crontab -
echo -e "${GREEN}Cron jobs configured${NC}"
echo ""

# Clean up installation files
echo -e "${YELLOW}STEP 17: Cleaning up installation files...${NC}"
rm -f /var/www/html/netbot/createDB.php
rm -f /var/www/html/netbot/install.sh
rm -f /var/www/html/netbot/netbot.sh
echo -e "${GREEN}Cleanup completed${NC}"
echo ""

# Final status check
echo -e "${YELLOW}Checking services...${NC}"

# Check if services are running
if systemctl is-active --quiet mysql; then
    echo -e "${GREEN}MySQL: Running${NC}"
else
    echo -e "${RED}MySQL: Failed${NC}"
fi

if systemctl is-active --quiet nginx; then
    echo -e "${GREEN}Nginx: Running${NC}"
else
    echo -e "${RED}Nginx: Failed${NC}"
fi

if systemctl is-active --quiet php8.1-fpm; then
    echo -e "${GREEN}PHP-FPM: Running${NC}"
else
    echo -e "${RED}PHP-FPM: Failed${NC}"
fi

# Display system info
echo -e "\n${YELLOW}System Information:${NC}"
echo -e "MySQL Version: $(mysql --version 2>/dev/null | cut -d' ' -f3 || echo 'Not available')"
echo -e "PHP Version: $(php -v 2>/dev/null | head -n1 | cut -d' ' -f2 || echo 'Not available')"
echo -e "Nginx Version: $(nginx -v 2>&1 | cut -d' ' -f3 | cut -d'/' -f2 || echo 'Not available')"

# Display memory usage
echo -e "\n${YELLOW}Memory Usage:${NC}"
free -h 2>/dev/null | head -n2 || echo "Memory info not available"

# Success message
echo ""
echo -e "${GREEN}================================================${NC}"
echo -e "${GREEN}    ALPHABOT INSTALLATION COMPLETE!           ${NC}"
echo -e "${GREEN}================================================${NC}"
echo ""

# Configuration summary
echo -e "${CYAN}================================================${NC}"
echo -e "${CYAN}           INSTALLATION SUMMARY                ${NC}"
echo -e "${CYAN}================================================${NC}"

echo -e "${BLUE}Bot URL:${NC}           ${GREEN}https://${DOMAIN_NAME}/netbot/${NC}"
echo -e "${BLUE}Database:${NC}            ${GREEN}netbot_db${NC}"
echo -e "${BLUE}DB User:${NC}             ${GREEN}netbot_user${NC}"
echo -e "${BLUE}DB Password:${NC}         ${GREEN}${randomdbpasstxt}${NC}"
echo -e "${BLUE}MySQL Root Pass:${NC}     ${GREEN}rootpass${NC}"
echo -e "${BLUE}Admin ID:${NC}            ${GREEN}${YOUR_CHAT_ID}${NC}"

echo ""

# Next steps
echo -e "${CYAN}================================================${NC}"
echo -e "${CYAN}              NEXT STEPS                       ${NC}"
echo -e "${CYAN}================================================${NC}"

echo -e "${YELLOW}1.${NC} ${PURPLE}Set up SSL certificate:${NC}"
echo -e "   ${CYAN}certbot --nginx -d ${DOMAIN_NAME}${NC}"
echo ""
echo -e "${YELLOW}2.${NC} ${PURPLE}Test your bot:${NC}"
echo -e "   ${CYAN}Send /start to your bot in Telegram${NC}"
echo ""
echo -e "${YELLOW}3.${NC} ${PURPLE}Monitor logs:${NC}"
echo -e "   ${CYAN}tail -f /var/log/nginx/error.log${NC}"

echo ""

# Troubleshooting section
echo -e "${CYAN}================================================${NC}"
echo -e "${CYAN}            TROUBLESHOOTING                    ${NC}"
echo -e "${CYAN}================================================${NC}"

echo -e "${YELLOW}If you encounter any issues, check the logs:${NC}"
echo -e "${BLUE}tail -f /var/log/nginx/error.log${NC}"
echo -e "${BLUE}tail -f /var/log/mysql/error.log${NC}"

echo ""

# Final success message
echo -e "${GREEN}AlphaBot is now ready and running!${NC}"
echo ""
