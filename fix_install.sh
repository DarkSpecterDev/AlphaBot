#!/bin/bash
# NetBot Installation Fix Script
# Fixes common installation issues

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}╔══════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║${NC}         ${GREEN}NetBot Fix Script${NC}           ${BLUE}║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════╝${NC}\n"

if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}This script must be run as root${NC}"
   exit 1
fi

# Fix MySQL OOM issues
echo -e "${YELLOW}Fixing MySQL memory issues...${NC}"
systemctl stop mysql
apt remove mysql-server mysql-server-8.0 -y --purge
apt autoremove -y
apt autoclean

# Clean MySQL data
rm -rf /var/lib/mysql
rm -rf /etc/mysql

# Create MySQL configuration for low memory
mkdir -p /etc/mysql/mysql.conf.d/
cat > /etc/mysql/mysql.conf.d/mysqld.cnf << EOF
[mysqld]
innodb_buffer_pool_size = 64M
innodb_log_file_size = 16M
innodb_log_buffer_size = 4M
query_cache_size = 16M
thread_cache_size = 4
table_open_cache = 32
performance_schema = OFF
EOF

# Reinstall MySQL with low memory config
export DEBIAN_FRONTEND=noninteractive
echo "mysql-server mysql-server/root_password password rootpass" | debconf-set-selections
echo "mysql-server mysql-server/root_password_again password rootpass" | debconf-set-selections
apt install -y mysql-server

# Fix Apache/Nginx conflicts
echo -e "${YELLOW}Fixing web server conflicts...${NC}"
systemctl stop apache2 2>/dev/null
systemctl disable apache2 2>/dev/null
apt remove apache2 apache2-utils -y 2>/dev/null

# Ensure Nginx is properly configured
systemctl enable nginx
systemctl start nginx

# Fix PHP version issues
echo -e "${YELLOW}Fixing PHP configuration...${NC}"
apt remove php8.4* -y 2>/dev/null
apt install -y php8.1 php8.1-fpm php8.1-mysql php8.1-curl php8.1-json php8.1-mbstring

# Start services
echo -e "${YELLOW}Starting services...${NC}"
systemctl start mysql
systemctl enable mysql
systemctl start php8.1-fpm
systemctl enable php8.1-fpm
systemctl restart nginx

# Wait for services to start
sleep 5

# Configure MySQL
echo -e "${YELLOW}Configuring MySQL...${NC}"
mysql -u root -prootpass -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'rootpass';" 2>/dev/null
mysql -u root -prootpass -e "FLUSH PRIVILEGES;" 2>/dev/null

# Check services status
echo -e "${YELLOW}Checking services status...${NC}"
systemctl status mysql --no-pager -l
systemctl status nginx --no-pager -l
systemctl status php8.1-fpm --no-pager -l

echo -e "\n${GREEN}Fix script completed!${NC}"
echo -e "${BLUE}MySQL root password: rootpass${NC}"
echo -e "${YELLOW}Now you can run the NetBot installation script again.${NC}" 