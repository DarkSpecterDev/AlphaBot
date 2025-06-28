#!/bin/bash
# NetBot Installation Fix Script
# Fixes MySQL OOM issues and PHP installation problems

set -e

echo "╔══════════════════════════════════════════╗"
echo "║         NetBot Installation Fix          ║"
echo "║         Fixing Installation Issues       ║"
echo "╚══════════════════════════════════════════╝"
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo "❌ Please run this script as root (use sudo)"
    exit 1
fi

# Stop all services
echo "🔄 Stopping all services..."
systemctl stop mysql 2>/dev/null || true
systemctl stop nginx 2>/dev/null || true
systemctl stop php8.1-fpm 2>/dev/null || true
systemctl stop apache2 2>/dev/null || true

# Clean up broken MySQL installation
echo "🧹 Cleaning up broken MySQL installation..."
apt-get purge -y mysql-server mysql-server-8.0 mysql-client mysql-client-8.0 mysql-common 2>/dev/null || true
apt-get autoremove -y 2>/dev/null || true
apt-get autoclean 2>/dev/null || true

# Remove MySQL data directory
rm -rf /var/lib/mysql
rm -rf /etc/mysql
rm -rf /var/log/mysql

# Fix broken packages
echo "🔧 Fixing broken packages..."
dpkg --configure -a
apt-get install -f -y

# Update package lists
echo "📦 Updating package lists..."
apt-get update

# Install MySQL with low memory configuration
echo "🗄️ Installing MySQL with optimized settings..."

# Pre-configure MySQL for low memory usage
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
thread_cache_size = 8
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
DEBIAN_FRONTEND=noninteractive apt-get install -y mysql-server mysql-client

# Start MySQL
systemctl start mysql
systemctl enable mysql

# Wait for MySQL to start
sleep 5

# Secure MySQL installation
mysql -u root -prootpass -e "
DELETE FROM mysql.user WHERE User='';
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
FLUSH PRIVILEGES;
"

echo "✅ MySQL installed successfully with optimized settings"

# Remove any existing PHP installations
echo "🔄 Cleaning up existing PHP installations..."
apt-get purge -y php* 2>/dev/null || true

# Install PHP 8.1 properly
echo "🐘 Installing PHP 8.1..."
apt-get install -y php8.1 php8.1-fpm php8.1-mysql php8.1-mbstring php8.1-xml php8.1-curl php8.1-zip php8.1-gd php8.1-cli php8.1-common

# Start and enable PHP-FPM
systemctl start php8.1-fpm
systemctl enable php8.1-fpm

# Install Nginx if not already installed
echo "🌐 Setting up Nginx..."
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

# Start services
echo "🚀 Starting services..."
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

# Check service status
echo ""
echo "📊 Service Status:"
echo "===================="
systemctl is-active mysql && echo "✅ MySQL: Running" || echo "❌ MySQL: Failed"
systemctl is-active nginx && echo "✅ Nginx: Running" || echo "❌ Nginx: Failed"
systemctl is-active php8.1-fpm && echo "✅ PHP-FPM: Running" || echo "❌ PHP-FPM: Failed"

echo ""
echo "🔧 System Information:"
echo "======================"
echo "MySQL Version: $(mysql --version 2>/dev/null || echo 'Not available')"
echo "PHP Version: $(php -v 2>/dev/null | head -n1 || echo 'Not available')"
echo "Nginx Version: $(nginx -v 2>&1 || echo 'Not available')"

echo ""
echo "💾 Memory Usage:"
echo "================"
free -h 2>/dev/null || echo "Memory info not available"

echo ""
echo "🎉 Installation fix completed!"
echo ""
echo "Next steps:"
echo "1. Clone NetBot to /var/www/html/netbot"
echo "2. Set up the database"
echo "3. Configure your bot token"
echo ""
echo "MySQL root password: rootpass"
echo "" 