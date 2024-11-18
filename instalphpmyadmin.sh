#!/bin/bash

# Color codes
RED='\e[1;31m'
GREEN='\e[1;32m'
RESET='\e[0m'
CYAN='\e[1;36m'
BOLD='\e[1m'

# Set environment variables
DB_HOST="178.128.17.191"
DB_USERNAME="u5_IswvFa3OCO"
DB_PASSWORD="0!^quZYF8FRIEPM5qEb^YPuP"
DB_NAME="s5_tokenbash"

# Display welcome message
clear
echo -e "${CYAN}${BOLD}****************************************"
echo -e "*                                    *"
echo -e "*   SELAMAT DATANG AUTO INSTALLER    *"
echo -e "*         BY FAJAR OFFICIAL          *"
echo -e "*                                    *"
echo -e "****************************************${RESET}"

# Ask for token input
read -p "Silahkan masukkan token: " user_token

# Token verification
TOKEN_EXISTS=$(mysql -h $DB_HOST -u $DB_USERNAME -p$DB_PASSWORD -D $DB_NAME -sse "SELECT EXISTS(SELECT 1 FROM tokens WHERE token='$user_token')")
if [ "$TOKEN_EXISTS" != 1 ]; then
  echo -e "${RED}Token salah, instalasi dibatalkan.${RESET}"
  exit 1
fi

# After successful token validation
clear
echo -e "${CYAN}${BOLD}****************************************"
echo -e "*                                    *"
echo -e "*    AUTO INSTALLER FAJAR OFFICIAL    *"
echo -e "*                                    *"
echo -e "****************************************${RESET}"

# Main menu for installer options
echo -e "${CYAN}Pilih opsi:${RESET}"
echo "1) Install phpMyAdmin"
echo "2) Create Database"
echo "3) Uninstall phpMyAdmin"
echo "4) Exit"

# Get user choice
read -p "Pilih opsi (1/2/3/4): " choice

case $choice in
  1)  # Install phpMyAdmin
      read -p "Masukkan domain untuk phpMyAdmin: " domainphp
      read -p "Apakah Anda yakin ingin menginstal phpMyAdmin? (y/n): " confirm
      if [[ $confirm == "y" || $confirm == "Y" ]]; then
        echo "Memulai instalasi phpMyAdmin..."
        
        # Create necessary directories
        mkdir -p /var/www/phpmyadmin/tmp && cd /var/www/phpmyadmin
        wget https://www.phpmyadmin.net/downloads/phpMyAdmin-latest-english.tar.gz
        tar xvzf phpMyAdmin-latest-english.tar.gz
        mv phpMyAdmin-*-english/* /var/www/phpmyadmin

        # Set permissions
        chown -R www-data:www-data * 
        mkdir config
        chmod o+rw config
        cp config.sample.inc.php config/config.inc.php
        chmod o+w config/config.inc.php

        # Configure nginx for phpMyAdmin
        cat > /etc/nginx/sites-available/phpmyadmin.conf << EOF
server {
    listen 80;
    server_name $domainphp;
    return 301 https://\$server_name\$request_uri;
}

server {
    listen 443 ssl http2;
    server_name $domainphp;

    root /var/www/phpmyadmin;
    index index.php;

    # SSL Configuration
    ssl_certificate /etc/letsencrypt/live/$domainphp/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/$domainphp/privkey.pem;

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location ~ \\.php\$ {
        fastcgi_pass unix:/run/php/php8.1-fpm.sock;
        fastcgi_index index.php;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
    }
}
EOF

        # Enable phpMyAdmin site and restart nginx
        sudo ln -s /etc/nginx/sites-available/phpmyadmin.conf /etc/nginx/sites-enabled/phpmyadmin.conf
        systemctl restart nginx
        echo -e "${GREEN}TERIMAKASIH SUDAH PAKAI AUTO INSTALLER PHPMYADMIN BY FAJAR OFFICIAL${RESET}"
      fi
      ;;
  
  2)  # Create Database
      read -p "Masukkan dbuser: " dbuser
      read -p "Masukkan IP database: " ipdb
      read -p "Masukkan password database: " pwdb
      read -p "Apakah Anda yakin ingin membuat database? (y/n): " confirm
      if [[ $confirm == "y" || $confirm == "Y" ]]; then
        echo "Membuat database..."
        mysql -u root -p -e "CREATE USER '$dbuser'@'$ipdb' IDENTIFIED BY '$pwdb';"
        mysql -u root -p -e "GRANT ALL PRIVILEGES ON *.* TO '$dbuser'@'$ipdb' WITH GRANT OPTION;"
        echo -e "${GREEN}DATABASE SUDAH DI BUAT BY FAJAR OFFICIAL${RESET}"
      fi
      ;;
  
  3)  # Uninstall phpMyAdmin
      read -p "Masukkan domain phpMyAdmin yang ingin dihapus: " domainphp
      read -p "Apakah Anda yakin ingin menghapus phpMyAdmin? (y/n): " confirm
      if [[ $confirm == "y" || $confirm == "Y" ]]; then
        echo "Menghapus phpMyAdmin..."
        sudo rm -rf /var/www/phpmyadmin
        sudo rm /etc/nginx/sites-available/phpmyadmin.conf
        sudo rm /etc/nginx/sites-enabled/phpmyadmin.conf
        systemctl restart nginx
        echo "phpMyAdmin berhasil dihapus."
      fi
      ;;
  
  4)  # Exit
      echo "Keluar dari installer."
      exit 0
      ;;
  
  *)  # Invalid Option
      echo -e "${RED}Pilihan tidak valid.${RESET}"
      exit 1
      ;;
esac

# Return to the main menu after any operation
exec $0
