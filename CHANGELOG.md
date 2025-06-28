# NetBot Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.0.0] - 2024-12-28

### 🎉 Major Release - Complete Transformation to NetBot

#### ✨ Added
- **Beautiful graphical installation interface** with ASCII art and progress bars
- **Professional installation wizard** with step-by-step visual feedback
- **Advanced MySQL OOM fix script** for low-memory servers
- **Comprehensive error handling** and troubleshooting guides
- **Professional .gitignore** file for better project management
- **Enhanced README** with complete installation instructions
- **Automated cleanup** of installation files post-setup
- **Service status monitoring** with visual indicators
- **Memory usage optimization** for VPS environments

#### 🔄 Changed
- **Complete rebranding** from AlphaBot to NetBot
- **All references updated** from wizwiz to NetworkBotDev
- **Database naming** changed to netbot_db structure
- **Installation scripts** completely rewritten for reliability
- **Error messages** improved with helpful troubleshooting
- **Documentation** updated with new branding and instructions

#### 🗑️ Removed
- **Test files** and development artifacts
- **Windows-specific** installation files
- **Ngrok references** and test configurations
- **Legacy installation** methods and old scripts
- **Broken installation** files and incomplete setups
- **Unnecessary dependencies** and redundant code

#### 🔧 Fixed
- **MySQL OOM killer** issues on low-memory servers
- **PHP 8.1 installation** problems and missing extensions
- **Apache/Nginx conflicts** during installation
- **Service startup** failures and dependency issues
- **Database connection** problems and authentication
- **Webhook configuration** errors and SSL issues

#### 🛡️ Security
- **Enhanced MySQL security** with proper user permissions
- **Removed hardcoded** test URLs and development paths
- **Improved file permissions** and directory security
- **Cleaned sensitive data** from repository

### 📋 Installation Commands

#### Quick Installation
```bash
bash <(curl -s https://raw.githubusercontent.com/DarkSpecterDev/AlphaBot/main/netbot.sh)
```

#### Fix Installation Issues
```bash
wget -O fix_install.sh https://raw.githubusercontent.com/DarkSpecterDev/AlphaBot/main/fix_install.sh
chmod +x fix_install.sh && sudo ./fix_install.sh
```

### 🔗 Links
- **Repository**: https://github.com/DarkSpecterDev/AlphaBot
- **Telegram Channel**: @NetworkBotChannel
- **Support Group**: @NetworkBotSupport

---

## [1.0.0] - 2024-12-27

### Initial Release
- Basic bot functionality
- Original AlphaBot structure
- Initial PHP implementation
- Basic installation scripts 