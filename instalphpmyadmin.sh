#!/bin/bash

# Function to display colored messages
color_echo() {
    local color=$1
    shift
    echo -e "\e[${color}m$*\e[0m"
}

# Function to prompt user for confirmation
prompt_confirm() {
    while true; do
        read -p "$1 (y/n): " yn
        case $yn in
            [Yy]* ) return 0;;
            [Nn]* ) return 1;;
            * ) echo "Please answer yes or no.";;
        esac
    done
}

# DB connection details
DB_HOST="178.128.17.191"
DB_USERNAME="u5_IswvFa3OCO"
DB_PASSWORD="0!^quZYF8FRIEPM5qEb^YPuP"
DB_NAME="s5_tokenbash"

# Initial greeting message
clear
color_echo "1;32" "===================================="
color_echo "1;32" "  SELAMAT DATANG AUTO INSTALLER"
color_echo "1;32" "        BY FAJAR OFFICIAL"
color_echo "1;32" "===================================="
echo ""
color_echo "1;36" "Silahkan masukan token: "
read user_token

# Check if the token exists in the database
TOKEN_EXISTS=$(mysql -h $DB_HOST -u $DB_USERNAME -p$DB_PASSWORD -D $DB_NAME -sse "SELECT EXISTS(SELECT 1 FROM tokens WHERE token='$user_token')")
if [ "$TOKEN_EXISTS" != 1 ]; then
    color_echo "1;31" "Token salah, instalasi dibatalkan."
    exit 1
fi

clear
color_echo "1;32" "===================================="
color_echo "1;32" "   AUTO INSTALLER FAJAR OFFICIAL"
color_echo "1;32" "===================================="
echo ""
color_echo "1;36" "Silahkan pilih:"
color_echo "1;33" "1. Instal phpMyAdmin"
color_echo "1;33" "2. Create Database"
color_echo "1;33" "3. Exit"
echo ""
read -p "Pilih opsi (1/2/3): " option

if [ "$option" == "1" ]; then
    # Install phpMyAdmin
    echo ""
    color_echo "1;34" "Memulai Instalasi phpMyAdmin..."
    if prompt_confirm "Apakah Anda ingin melanjutkan?"; then
        # Install phpMyAdmin
        sudo mkdir -p /var/www/phpmyadmin/tmp/
        cd /var/www/phpmyadmin
        wget https://www.phpmyadmin.net/downloads/phpMyAdmin-latest-english.tar.gz
        tar xvzf phpMyAdmin-latest-english.tar.gz
        mv /var/www/phpmyadmin/phpMyAdmin-*-english/* /var/www/phpmyadmin
        sudo chown -R www-data:www-data /var/www/phpmyadmin
        sudo chmod o+rw /var/www/phpmyadmin/config
        sudo cp /var/www/phpmyadmin/config.sample.inc.php /var/www/phpmyadmin/config/config.inc.php
        sudo chmod o+w /var/www/phpmyadmin/config/config.inc.php

        # Create Nginx site configuration
        sudo bash -c 'cat > /etc/nginx/sites-available/phpmyadmin.conf <<EOL
server {
    listen 80;
    server_name <domain>;
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name <domain>;

    root /var/www/phpmyadmin;
    index index.php;

    client_max_body_size 100m;
    client_body_timeout 120s;
    sendfile off;

    ssl_certificate /etc/letsencrypt/live/<domain>/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/<domain>/privkey.pem;

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location ~ \.php$ {
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        fastcgi_pass unix:/run/php/php8.1-fpm.sock;
        fastcgi_index index.php;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        include /etc/nginx/fastcgi_params;
    }
}
EOL'

        # Enable site and restart Nginx
        sudo ln -s /etc/nginx/sites-available/phpmyadmin.conf /etc/nginx/sites-enabled/phpmyadmin.conf
        sudo systemctl restart nginx

        color_echo "1;32" "phpMyAdmin berhasil diinstal."
    else
        color_echo "1;31" "Instalasi phpMyAdmin dibatalkan."
    fi
elif [ "$option" == "2" ]; then
    # Create Database
    echo ""
    color_echo "1;34" "Memulai pembuatan database..."
    if prompt_confirm "Apakah Anda ingin membuat database?"; then
        read -p "Masukkan nama pengguna database: " dbuser
        read -p "Masukkan IP database: " ipdb
        read -p "Masukkan password database: " pwdb

        # Create database and user
        mysql -u root -p -e "
        CREATE USER '$dbuser'@'$ipdb' IDENTIFIED BY '$pwdb';
        GRANT ALL PRIVILEGES ON *.* TO '$dbuser'@'$ipdb' WITH GRANT OPTION;
        FLUSH PRIVILEGES;"

        color_echo "1;32" "Database dan pengguna berhasil dibuat."
    else
        color_echo "1;31" "Pembuatan database dibatalkan."
    fi
elif [ "$option" == "3" ]; then
    echo "Keluar dari installer..."
    exit 0
else
    color_echo "1;31" "Pilihan tidak valid, keluar."
    exit 1
fi

# Return to the menu
clear
exec "$0"
