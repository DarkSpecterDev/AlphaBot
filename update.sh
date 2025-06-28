#!/bin/bash
# NetBot Update Script
# Written By: NetworkBotDev

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}╔══════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║${NC}         ${GREEN}NetBot Update${NC}              ${BLUE}║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════╝${NC}\n"

if [[ $EUID -eq 0 ]]; then
   echo ""
else
   echo -e "${RED}This script must be run as root${NC}"
   exit 1
fi

echo -e "${YELLOW}Backing up configuration...${NC}"
cp /var/www/html/netbot/baseInfo.php /root/

echo -e "${YELLOW}Downloading latest version...${NC}"
rm -r /var/www/html/netbot/

git clone https://github.com/NetworkBotDev/NetBot.git /var/www/html/netbot
sudo chown -R www-data:www-data /var/www/html/netbot/
sudo chmod -R 755 /var/www/html/netbot/

echo -e "${YELLOW}Restoring configuration...${NC}"
mv /root/baseInfo.php /var/www/html/netbot/

# Get database info
db_name=$(cat /var/www/html/netbot/baseInfo.php | grep '$dbName' | cut -d"'" -f2)
db_user=$(cat /var/www/html/netbot/baseInfo.php | grep '$dbUserName' | cut -d"'" -f2)
db_pass=$(cat /var/www/html/netbot/baseInfo.php | grep '$dbPassword' | cut -d"'" -f2)
bot_token=$(cat /var/www/html/netbot/baseInfo.php | grep '$botToken' | cut -d"'" -f2)
admin_id=$(cat /var/www/html/netbot/baseInfo.php | grep '$admin' | cut -d"'" -f2)

echo -e "${YELLOW}Updating database...${NC}"
curl "https://$(hostname)/netbot/createDB.php"

echo -e "${YELLOW}Cleaning up...${NC}"
rm -f /var/www/html/netbot/createDB.php
rm -f /var/www/html/netbot/install.sh
rm -f /var/www/html/netbot/netbot.sh

echo -e "\n${GREEN}╔══════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║${NC}     ${CYAN}NetBot Updated Successfully!${NC}      ${GREEN}║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════╝${NC}\n"

echo -e "${BLUE}Database:${NC} ${db_name}"
echo -e "${BLUE}DB User:${NC} ${db_user}"
echo -e "${BLUE}Admin ID:${NC} ${admin_id}"

echo -e "\n${GREEN}Update completed successfully!${NC}"
