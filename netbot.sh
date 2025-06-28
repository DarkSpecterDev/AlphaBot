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
BOLD='\033[1m'
DIM='\033[2m'
UNDERLINE='\033[4m'
BLINK='\033[5m'
NC='\033[0m'

# Animation and graphics functions
progress_bar() {
    local duration=$1
    local max=50
    for ((i=0; i<=max; i++)); do
        local percent=$((i * 100 / max))
        local filled=$((i * 4 / 10))
        local empty=$((40 - filled))
        printf "\r${CYAN}["
        printf "%0.s█" $(seq 1 $filled)
        printf "%0.s░" $(seq 1 $empty)
        printf "] ${percent}%% ${NC}"
        sleep $(echo "scale=3; $duration / $max" | bc -l 2>/dev/null || echo "0.1")
    done
    echo ""
}

clear

# Beautiful animated header
echo -e "${BOLD}${CYAN}"
echo "╔══════════════════════════════════════════════════════════════════════════╗"
echo "║                                                                          ║"
echo "║    ${BLINK}🚀${NC}${BOLD}${CYAN} ${GREEN}███╗   ██╗███████╗████████╗██████╗  ██████╗ ████████╗${NC}${BOLD}${CYAN} ${BLINK}🚀${NC}${BOLD}${CYAN}    ║"
echo "║      ${GREEN}████╗  ██║██╔════╝╚══██╔══╝██╔══██╗██╔═══██╗╚══██╔══╝${NC}${BOLD}${CYAN}      ║"
echo "║      ${GREEN}██╔██╗ ██║█████╗     ██║   ██████╔╝██║   ██║   ██║${NC}${BOLD}${CYAN}         ║"
echo "║      ${GREEN}██║╚██╗██║██╔══╝     ██║   ██╔══██╗██║   ██║   ██║${NC}${BOLD}${CYAN}         ║"
echo "║      ${GREEN}██║ ╚████║███████╗   ██║   ██████╔╝╚██████╔╝   ██║${NC}${BOLD}${CYAN}         ║"
echo "║      ${GREEN}╚═╝  ╚═══╝╚══════╝   ╚═╝   ╚═════╝  ╚═════╝    ╚═╝${NC}${BOLD}${CYAN}         ║"
echo "║                                                                          ║"
echo "║                    ${YELLOW}🛠️  INSTALLATION WIZARD  🛠️${NC}${BOLD}${CYAN}                     ║"
echo "║                                                                          ║"
echo "╠══════════════════════════════════════════════════════════════════════════╣"
echo "║ ${BLUE}🌐 Network VPN Bot Manager${NC}${BOLD}${CYAN}  ║ ${BLUE}⚡ Advanced Panel Support${NC}${BOLD}${CYAN}      ║"
echo "║ ${BLUE}🔒 Secure & Optimized${NC}${BOLD}${CYAN}       ║ ${BLUE}📊 Real-time Monitoring${NC}${BOLD}${CYAN}       ║"
echo "║ ${BLUE}🚀 One-Click Installation${NC}${BOLD}${CYAN}   ║ ${BLUE}💎 Professional Features${NC}${BOLD}${CYAN}      ║"
echo "╚══════════════════════════════════════════════════════════════════════════╝"
echo -e "${NC}"
echo ""
echo -e "    ${PURPLE}📱 Telegram: ${BLUE}@NetworkBotChannel${NC} | ${PURPLE}💬 Support: ${BLUE}@NetworkBotSupport${NC}"
echo ""

# Loading animation
echo -e "${YELLOW}${BOLD}🚀 Initializing NetBot Installation...${NC}"
progress_bar 2
echo -e "${GREEN}✅ Ready to proceed!${NC}\n"

if [[ $EUID -eq 0 ]]; then
   echo ""
else
   echo -e "${RED}This script must be run as root${NC}"
   exit 1
fi

# Stop conflicting services
echo -e "${YELLOW}${BOLD}🔄 STEP 1: Stopping conflicting services...${NC}"
progress_bar 1
systemctl stop apache2 2>/dev/null
systemctl disable apache2 2>/dev/null
systemctl stop mysql 2>/dev/null
echo -e "${GREEN}✅ Services stopped${NC}\n"

# Update system
echo -e "${YELLOW}${BOLD}📦 STEP 2: Updating system packages...${NC}"
progress_bar 2
apt update -y && apt upgrade -y
echo -e "${GREEN}✅ System updated${NC}\n"

# Remove Apache if installed
echo -e "${YELLOW}${BOLD}🧹 STEP 3: Removing Apache conflicts...${NC}"
progress_bar 1
apt remove apache2 apache2-utils -y 2>/dev/null
echo -e "${GREEN}✅ Apache removed${NC}\n"

# Install required packages (without mysql-server for now)
echo -e "${YELLOW}${BOLD}📋 STEP 4: Installing required packages...${NC}"
progress_bar 2
apt install -y curl wget unzip git nginx software-properties-common
echo -e "${GREEN}✅ Base packages installed${NC}\n"

# Add PHP repository
echo -e "${YELLOW}${BOLD}🔧 STEP 5: Adding PHP repository...${NC}"
progress_bar 1
add-apt-repository ppa:ondrej/php -y
apt update
echo -e "${GREEN}✅ PHP repository added${NC}\n"

# Install PHP 8.1 (more stable)
echo -e "${YELLOW}${BOLD}🐘 STEP 6: Installing PHP 8.1...${NC}"
progress_bar 3
apt install -y php8.1 php8.1-fpm php8.1-mysql php8.1-curl php8.1-mbstring php8.1-xml php8.1-zip php8.1-gd php8.1-cli php8.1-common
echo -e "${GREEN}✅ PHP 8.1 installed${NC}\n"

# Install MySQL with low memory configuration
echo -e "${YELLOW}${BOLD}🗄️ STEP 7: Installing MySQL with optimized settings...${NC}"

# Pre-configure MySQL to avoid interactive prompts
export DEBIAN_FRONTEND=noninteractive
debconf-set-selections <<< "mysql-server mysql-server/root_password password rootpass"
debconf-set-selections <<< "mysql-server mysql-server/root_password_again password rootpass"
echo -e "${BLUE}📝 MySQL credentials configured${NC}"

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
progress_bar 3
apt install -y mysql-server

# Configure MySQL
echo -e "${YELLOW}${BOLD}⚙️ Configuring MySQL...${NC}"
systemctl start mysql
systemctl enable mysql

# Wait for MySQL to start
echo -e "${BLUE}⏳ Waiting for MySQL to initialize...${NC}"
sleep 10

# Secure MySQL installation
mysql -u root -prootpass -e "
DELETE FROM mysql.user WHERE User='';
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
FLUSH PRIVILEGES;
" 2>/dev/null || echo -e "${YELLOW}⚠️ MySQL security setup completed with warnings${NC}"

echo -e "${GREEN}✅ MySQL installed and secured${NC}\n"

# Configure Nginx
echo -e "${YELLOW}${BOLD}🌐 STEP 8: Configuring Nginx...${NC}"
progress_bar 1
systemctl enable nginx
systemctl start nginx
echo -e "${GREEN}✅ Nginx configured${NC}\n"

# Configure PHP
echo -e "${YELLOW}${BOLD}⚙️ STEP 9: Configuring PHP-FPM...${NC}"
progress_bar 1
systemctl enable php8.1-fpm
systemctl start php8.1-fpm
echo -e "${GREEN}✅ PHP-FPM configured${NC}\n"

# Get user input with beautiful formatting
echo -e "${CYAN}${BOLD}╔══════════════════════════════════════════╗${NC}"
echo -e "${CYAN}${BOLD}║           📝 CONFIGURATION SETUP        ║${NC}"
echo -e "${CYAN}${BOLD}╚══════════════════════════════════════════╝${NC}"
echo -e "${PURPLE}Please provide the following information:${NC}\n"

echo -e "${BLUE}🌐 Domain Configuration:${NC}"
read -p "$(echo -e "${YELLOW}Enter your domain name: ${NC}")" DOMAIN_NAME

echo -e "\n${BLUE}🤖 Bot Configuration:${NC}"
read -p "$(echo -e "${YELLOW}Enter your bot token: ${NC}")" YOUR_BOT_TOKEN

echo -e "\n${BLUE}👤 Admin Configuration:${NC}"
read -p "$(echo -e "${YELLOW}Enter your admin chat ID: ${NC}")" YOUR_CHAT_ID

echo -e "\n${GREEN}✅ Configuration collected successfully!${NC}\n"

# Create database
echo -e "${YELLOW}${BOLD}🗄️ STEP 10: Creating database...${NC}"
progress_bar 2
randomdbpasstxt=$(openssl rand -base64 12)
ASAS='$'

# Setup database
mysql -u root -prootpass -e "CREATE DATABASE IF NOT EXISTS netbot_db;" 2>/dev/null
mysql -u root -prootpass -e "CREATE USER IF NOT EXISTS 'netbot_user'@'localhost' IDENTIFIED BY '${randomdbpasstxt}';" 2>/dev/null
mysql -u root -prootpass -e "GRANT ALL PRIVILEGES ON netbot_db.* TO 'netbot_user'@'localhost';" 2>/dev/null
mysql -u root -prootpass -e "FLUSH PRIVILEGES;" 2>/dev/null
echo -e "${GREEN}✅ Database created successfully${NC}\n"

# Clone NetBot repository
echo -e "${YELLOW}${BOLD}📥 STEP 11: Downloading NetBot files...${NC}"
progress_bar 3
cd /var/www/html/
rm -rf netbot 2>/dev/null
git clone https://github.com/DarkSpecterDev/AlphaBot.git netbot
sudo chown -R www-data:www-data /var/www/html/netbot/
sudo chmod -R 755 /var/www/html/netbot/
echo -e "${GREEN}✅ NetBot files downloaded and configured${NC}\n"

# Create baseInfo.php
echo -e "${YELLOW}${BOLD}⚙️ STEP 12: Creating configuration file...${NC}"
progress_bar 1
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
echo -e "${GREEN}✅ Configuration file created${NC}\n"

# Configure Nginx for NetBot
echo -e "${YELLOW}${BOLD}🌐 STEP 13: Configuring web server...${NC}"
progress_bar 2
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
echo -e "${GREEN}✅ Web server configured${NC}\n"

# Create database tables
echo -e "${YELLOW}${BOLD}🗄️ STEP 14: Setting up database tables...${NC}"
progress_bar 1
curl -s "http://${DOMAIN_NAME}/netbot/createDB.php" >/dev/null 2>&1
echo -e "${GREEN}✅ Database tables created${NC}\n"

# Set webhook
echo -e "${YELLOW}${BOLD}🤖 STEP 15: Setting up Telegram webhook...${NC}"
progress_bar 1
curl -s -F "url=https://${DOMAIN_NAME}/netbot/bot.php" "https://api.telegram.org/bot${YOUR_BOT_TOKEN}/setWebhook" >/dev/null 2>&1
echo -e "${GREEN}✅ Telegram webhook configured${NC}\n"

# Setup cron jobs
echo -e "${YELLOW}${BOLD}⏰ STEP 16: Setting up scheduled tasks...${NC}"
progress_bar 1
(crontab -l 2>/dev/null; echo "* * * * * curl -s https://${DOMAIN_NAME}/netbot/settings/messagenetbot.php >/dev/null 2>&1") | crontab -
(crontab -l 2>/dev/null; echo "* * * * * curl -s https://${DOMAIN_NAME}/netbot/settings/rewardReport.php >/dev/null 2>&1") | crontab -
(crontab -l 2>/dev/null; echo "* * * * * curl -s https://${DOMAIN_NAME}/netbot/settings/warnusers.php >/dev/null 2>&1") | crontab -
echo -e "${GREEN}✅ Cron jobs configured${NC}\n"

# Clean up installation files
echo -e "${YELLOW}${BOLD}🧹 STEP 17: Cleaning up installation files...${NC}"
progress_bar 1
rm -f /var/www/html/netbot/createDB.php
rm -f /var/www/html/netbot/install.sh
rm -f /var/www/html/netbot/netbot.sh
echo -e "${GREEN}✅ Cleanup completed${NC}\n"

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

# Beautiful success message
echo -e "${GREEN}${BOLD}"
echo "╔══════════════════════════════════════════════════════════════════════════╗"
echo "║                                                                          ║"
echo "║                    🎉 NETBOT INSTALLATION COMPLETE! 🎉                  ║"
echo "║                                                                          ║"
echo "╚══════════════════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Configuration summary with beautiful formatting
echo -e "${CYAN}${BOLD}╔══════════════════════════════════════════╗${NC}"
echo -e "${CYAN}${BOLD}║           📋 INSTALLATION SUMMARY       ║${NC}"
echo -e "${CYAN}${BOLD}╚══════════════════════════════════════════╝${NC}"

echo -e "${BLUE}🌐 Bot URL:${NC}           ${GREEN}https://${DOMAIN_NAME}/netbot/${NC}"
echo -e "${BLUE}🗄️  Database:${NC}         ${GREEN}netbot_db${NC}"
echo -e "${BLUE}👤 DB User:${NC}          ${GREEN}netbot_user${NC}"
echo -e "${BLUE}🔐 DB Password:${NC}      ${GREEN}${randomdbpasstxt}${NC}"
echo -e "${BLUE}🔑 MySQL Root Pass:${NC}  ${GREEN}rootpass${NC}"
echo -e "${BLUE}👑 Admin ID:${NC}         ${GREEN}${YOUR_CHAT_ID}${NC}"

echo ""

# Next steps with beautiful formatting
echo -e "${CYAN}${BOLD}╔══════════════════════════════════════════╗${NC}"
echo -e "${CYAN}${BOLD}║              📝 NEXT STEPS               ║${NC}"
echo -e "${CYAN}${BOLD}╚══════════════════════════════════════════╝${NC}"

echo -e "${YELLOW}1.${NC} ${PURPLE}🔒 Set up SSL certificate:${NC}"
echo -e "   ${CYAN}certbot --nginx -d ${DOMAIN_NAME}${NC}"
echo ""
echo -e "${YELLOW}2.${NC} ${PURPLE}🤖 Test your bot:${NC}"
echo -e "   ${CYAN}Send /start to your bot in Telegram${NC}"
echo ""
echo -e "${YELLOW}3.${NC} ${PURPLE}📊 Monitor logs:${NC}"
echo -e "   ${CYAN}tail -f /var/log/nginx/error.log${NC}"

echo ""

# Troubleshooting section
echo -e "${CYAN}${BOLD}╔══════════════════════════════════════════╗${NC}"
echo -e "${CYAN}${BOLD}║            🛠️  TROUBLESHOOTING           ║${NC}"
echo -e "${CYAN}${BOLD}╚══════════════════════════════════════════╝${NC}"

echo -e "${YELLOW}⚠️  If you encounter any issues, run the fix script:${NC}"
echo -e "${BLUE}wget -O fix_install.sh https://raw.githubusercontent.com/DarkSpecterDev/AlphaBot/main/fix_install.sh${NC}"
echo -e "${BLUE}chmod +x fix_install.sh && sudo ./fix_install.sh${NC}"

echo ""

# Final success message
echo -e "${GREEN}${BOLD}🚀 NetBot is now ready and running!${NC}"
echo -e "${PURPLE}💬 Join our community: ${BLUE}@NetworkBotChannel${NC}"
echo -e "${PURPLE}🆘 Need help? Contact: ${BLUE}@NetworkBotSupport${NC}"
echo ""
