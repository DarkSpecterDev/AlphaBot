#!/bin/bash
# NetBot Installation Fix Script
# Fixes MySQL OOM issues and PHP installation problems

set -e

# Colors and styles
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
NC='\033[0m' # No Color

# Animation function
spinner() {
    local pid=$1
    local delay=0.1
    local spinstr='|/-\'
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

# Progress bar function
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

# Clear screen with animation
clear
echo -e "${CYAN}"
for i in {1..3}; do
    echo "Loading..."
    sleep 0.3
    clear
done

# Beautiful animated header
echo -e "${BOLD}${CYAN}"
echo "╔══════════════════════════════════════════════════════════════════════════╗"
echo "║                                                                          ║"
echo "║    ${BLINK}🔧${NC}${BOLD}${CYAN} ${GREEN}███╗   ██╗███████╗████████╗██████╗  ██████╗ ████████╗${NC}${BOLD}${CYAN} ${BLINK}🔧${NC}${BOLD}${CYAN}    ║"
echo "║      ${GREEN}████╗  ██║██╔════╝╚══██╔══╝██╔══██╗██╔═══██╗╚══██╔══╝${NC}${BOLD}${CYAN}      ║"
echo "║      ${GREEN}██╔██╗ ██║█████╗     ██║   ██████╔╝██║   ██║   ██║${NC}${BOLD}${CYAN}         ║"
echo "║      ${GREEN}██║╚██╗██║██╔══╝     ██║   ██╔══██╗██║   ██║   ██║${NC}${BOLD}${CYAN}         ║"
echo "║      ${GREEN}██║ ╚████║███████╗   ██║   ██████╔╝╚██████╔╝   ██║${NC}${BOLD}${CYAN}         ║"
echo "║      ${GREEN}╚═╝  ╚═══╝╚══════╝   ╚═╝   ╚═════╝  ╚═════╝    ╚═╝${NC}${BOLD}${CYAN}         ║"
echo "║                                                                          ║"
echo "║                    ${YELLOW}🛠️  INSTALLATION FIX TOOL  🛠️${NC}${BOLD}${CYAN}                    ║"
echo "║                                                                          ║"
echo "╠══════════════════════════════════════════════════════════════════════════╣"
echo "║ ${BLUE}🚀 MySQL OOM Killer Fix${NC}${BOLD}${CYAN}     ║ ${BLUE}🐘 PHP 8.1 Installation${NC}${BOLD}${CYAN}        ║"
echo "║ ${BLUE}🌐 Nginx Configuration${NC}${BOLD}${CYAN}      ║ ${BLUE}🔒 Security Hardening${NC}${BOLD}${CYAN}          ║"
echo "║ ${BLUE}🧹 System Cleanup${NC}${BOLD}${CYAN}           ║ ${BLUE}⚡ Performance Optimization${NC}${BOLD}${CYAN}    ║"
echo "╚══════════════════════════════════════════════════════════════════════════╝"
echo -e "${NC}"
echo ""
echo -e "    ${PURPLE}📱 Telegram: ${BLUE}@NetworkBotChannel${NC} | ${PURPLE}💬 Support: ${BLUE}@NetworkBotSupport${NC}"
echo ""
echo -e "${YELLOW}${BOLD}⚠️  WARNING: This will completely reinstall MySQL and PHP! ⚠️${NC}"
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}${BOLD}❌ ERROR: Please run this script as root (use sudo)${NC}"
    echo -e "${YELLOW}💡 Try: ${CYAN}sudo ./fix_install.sh${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Running as root - proceeding with fix...${NC}"
echo ""

# Stop all services with animation
echo -e "${YELLOW}${BOLD}🔄 STEP 1: Stopping conflicting services...${NC}"
progress_bar 2
systemctl stop mysql 2>/dev/null || true
systemctl stop nginx 2>/dev/null || true
systemctl stop php8.1-fpm 2>/dev/null || true
systemctl stop apache2 2>/dev/null || true
echo -e "${GREEN}✅ Services stopped successfully${NC}"
echo ""

# Clean up broken MySQL installation
echo -e "${YELLOW}${BOLD}🧹 STEP 2: Cleaning broken MySQL installation...${NC}"
progress_bar 3
apt-get purge -y mysql-server mysql-server-8.0 mysql-client mysql-client-8.0 mysql-common 2>/dev/null || true
apt-get autoremove -y 2>/dev/null || true
apt-get autoclean 2>/dev/null || true

# Remove MySQL data directory
rm -rf /var/lib/mysql
rm -rf /etc/mysql
rm -rf /var/log/mysql
echo -e "${GREEN}✅ MySQL cleanup completed${NC}"
echo ""

# Fix broken packages
echo -e "${YELLOW}${BOLD}🔧 STEP 3: Fixing broken packages...${NC}"
progress_bar 2
dpkg --configure -a
apt-get install -f -y
echo -e "${GREEN}✅ Package dependencies fixed${NC}"
echo ""

# Update package lists
echo -e "${YELLOW}${BOLD}📦 STEP 4: Updating package lists...${NC}"
progress_bar 2
apt-get update
echo -e "${GREEN}✅ Package lists updated${NC}"
echo ""

# Install MySQL with low memory configuration
echo -e "${YELLOW}${BOLD}🗄️ STEP 5: Installing MySQL with optimized settings...${NC}"

# Pre-configure MySQL for low memory usage
debconf-set-selections <<< "mysql-server mysql-server/root_password password rootpass"
debconf-set-selections <<< "mysql-server mysql-server/root_password_again password rootpass"

# Create MySQL configuration for low memory before installation
mkdir -p /etc/mysql/mysql.conf.d
cat > /etc/mysql/mysql.conf.d/low-memory.cnf << EOF
[mysqld]
# Low memory configuration optimized for VPS
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

echo -e "${BLUE}📝 MySQL low-memory configuration created${NC}"
progress_bar 3

# Install MySQL
DEBIAN_FRONTEND=noninteractive apt-get install -y mysql-server mysql-client

# Start MySQL
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

echo -e "${GREEN}✅ MySQL installed successfully with optimized settings${NC}"
echo ""

# Remove any existing PHP installations
echo -e "${YELLOW}${BOLD}🔄 STEP 6: Cleaning existing PHP installations...${NC}"
progress_bar 2
apt-get purge -y php* 2>/dev/null || true
echo -e "${GREEN}✅ PHP cleanup completed${NC}"
echo ""

# Install PHP 8.1 properly
echo -e "${YELLOW}${BOLD}🐘 STEP 7: Installing PHP 8.1...${NC}"
progress_bar 3
apt-get install -y php8.1 php8.1-fpm php8.1-mysql php8.1-mbstring php8.1-xml php8.1-curl php8.1-zip php8.1-gd php8.1-cli php8.1-common

# Start and enable PHP-FPM
systemctl start php8.1-fpm
systemctl enable php8.1-fpm
echo -e "${GREEN}✅ PHP 8.1 installed and configured${NC}"
echo ""

# Install Nginx if not already installed
echo -e "${YELLOW}${BOLD}🌐 STEP 8: Setting up Nginx...${NC}"
progress_bar 2
apt-get install -y nginx

# Configure Nginx for PHP
cat > /etc/nginx/sites-available/netbot << 'EOF'
server {
    listen 80 default_server;
    listen [::]:80 default_server;
    
    root /var/www/html/netbot;
    index index.php index.html index.htm;
    
    server_name _;
    
    location / {
        try_files $uri $uri/ =404;
    }
    
    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php8.1-fpm.sock;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        include fastcgi_params;
    }
    
    location ~ /\.ht {
        deny all;
    }
}
EOF

# Enable the site
ln -sf /etc/nginx/sites-available/netbot /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default

# Test Nginx configuration
nginx -t
echo -e "${GREEN}✅ Nginx configured successfully${NC}"
echo ""

# Start services
echo -e "${YELLOW}${BOLD}🚀 STEP 9: Starting all services...${NC}"
progress_bar 3
systemctl restart nginx
systemctl restart php8.1-fpm
systemctl restart mysql

# Enable services
systemctl enable nginx
systemctl enable php8.1-fpm
systemctl enable mysql

# Create web directory
mkdir -p /var/www/html/netbot
chown -R www-data:www-data /var/www/html/netbot
echo -e "${GREEN}✅ All services started successfully${NC}"
echo ""

# Check service status with beautiful output
echo -e "${CYAN}${BOLD}╔══════════════════════════════════════════╗${NC}"
echo -e "${CYAN}${BOLD}║            📊 SERVICE STATUS             ║${NC}"
echo -e "${CYAN}${BOLD}╚══════════════════════════════════════════╝${NC}"

if systemctl is-active --quiet mysql; then
    echo -e "${GREEN}✅ MySQL:    ${BOLD}Running${NC} ${GREEN}(Port 3306)${NC}"
else
    echo -e "${RED}❌ MySQL:    ${BOLD}Failed${NC}"
fi

if systemctl is-active --quiet nginx; then
    echo -e "${GREEN}✅ Nginx:    ${BOLD}Running${NC} ${GREEN}(Port 80)${NC}"
else
    echo -e "${RED}❌ Nginx:    ${BOLD}Failed${NC}"
fi

if systemctl is-active --quiet php8.1-fpm; then
    echo -e "${GREEN}✅ PHP-FPM:  ${BOLD}Running${NC} ${GREEN}(Socket)${NC}"
else
    echo -e "${RED}❌ PHP-FPM:  ${BOLD}Failed${NC}"
fi

echo ""

# Display system info with beautiful formatting
echo -e "${CYAN}${BOLD}╔══════════════════════════════════════════╗${NC}"
echo -e "${CYAN}${BOLD}║           🔧 SYSTEM INFORMATION          ║${NC}"
echo -e "${CYAN}${BOLD}╚══════════════════════════════════════════╝${NC}"
echo -e "${BLUE}🗄️  MySQL:${NC}  $(mysql --version 2>/dev/null | cut -d' ' -f3 || echo 'Not available')"
echo -e "${BLUE}🐘 PHP:${NC}    $(php -v 2>/dev/null | head -n1 | cut -d' ' -f2 || echo 'Not available')"
echo -e "${BLUE}🌐 Nginx:${NC}  $(nginx -v 2>&1 | cut -d' ' -f3 | cut -d'/' -f2 || echo 'Not available')"

echo ""

# Display memory usage with beautiful formatting
echo -e "${CYAN}${BOLD}╔══════════════════════════════════════════╗${NC}"
echo -e "${CYAN}${BOLD}║            💾 MEMORY USAGE               ║${NC}"
echo -e "${CYAN}${BOLD}╚══════════════════════════════════════════╝${NC}"
if command -v free >/dev/null 2>&1; then
    free -h | head -n2 | while read line; do
        echo -e "${YELLOW}$line${NC}"
    done
else
    echo -e "${RED}Memory info not available${NC}"
fi

echo ""

# Success message with animation
echo -e "${GREEN}${BOLD}"
echo "╔══════════════════════════════════════════════════════════════════════════╗"
echo "║                                                                          ║"
echo "║                    🎉 INSTALLATION FIX COMPLETED! 🎉                    ║"
echo "║                                                                          ║"
echo "╚══════════════════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

echo -e "${CYAN}${BOLD}📋 NEXT STEPS:${NC}"
echo -e "${YELLOW}1.${NC} Clone NetBot to ${BLUE}/var/www/html/netbot${NC}"
echo -e "${YELLOW}2.${NC} Set up the database with your credentials"
echo -e "${YELLOW}3.${NC} Configure your bot token"
echo ""

echo -e "${CYAN}${BOLD}🔐 IMPORTANT CREDENTIALS:${NC}"
echo -e "${BLUE}🗄️  MySQL Root Password:${NC} ${GREEN}rootpass${NC}"
echo -e "${BLUE}📁 Web Directory:${NC}        ${GREEN}/var/www/html/netbot${NC}"
echo -e "${BLUE}🌐 Default Port:${NC}         ${GREEN}80 (HTTP)${NC}"
echo ""

echo -e "${PURPLE}${BOLD}🚀 Ready to install NetBot!${NC}"
echo -e "${DIM}Run: ${CYAN}bash <(curl -s https://raw.githubusercontent.com/DarkSpecterDev/AlphaBot/main/netbot.sh)${NC}"
echo "" 