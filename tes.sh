#!/bin/bash

# Definisikan warna
RED='\e[1;31m'
GREEN='\e[1;32m'
YELLOW='\e[1;33m'
BLUE='\e[1;34m'
MAGENTA='\e[1;35m'
CYAN='\e[1;36m'
RESET='\e[0m'

# Fungsi untuk menampilkan teks besar
big_text() {
    echo -e "\e[1;36m"
    echo -e "███████╗██╗      █████╗ ███╗   ██╗████████╗ ██████╗ ███████╗"
    echo -e "╚══███╔╝██║     ██╔══██╗████╗  ██║╚══██╔══╝██╔══██╗██╔════╝"
    echo -e "   ███╔╝ ██╗     ███████║██╔██╗ ██║   ██║   ██████╔╝███████╗"
    echo -e "  ███╔╝  ██║     ██╔══██║██║╚██╗██║   ██║   ██╔══██╗╚════██║"
    echo -e "  ███████╗███████╗██║  ██║██║ ╚████║   ██║   ██║  ██║███████║"
    echo -e "  ╚══════╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═══╝   ╚═╝   ╚═╝  ╚═╝╚══════╝"
    echo -e "\e[1;32mSELAMAT DATANG AUTO INSTALLER BY FAJAR OFFICIAL\e[0m"
}

# Fungsi untuk verifikasi token
verify_token() {
    read -p "Masukkan token Anda: " user_token

    DB_HOST="178.128.17.191"
    DB_USERNAME="u5_IswvFa3OCO"
    DB_PASSWORD="0!^quZYF8FRIEPM5qEb^YPuP"
    DB_NAME="s5_tokenbash"

    TOKEN_EXISTS=$(mysql -h $DB_HOST -u $DB_USERNAME -p$DB_PASSWORD -D $DB_NAME -sse "SELECT EXISTS(SELECT 1 FROM tokens WHERE token='$user_token')")

    if [ "$TOKEN_EXISTS" != 1 ]; then
        echo -e "\e[1;31mToken salah, instalasi dibatalkan.\e[0m"
        exit 1
    fi
    echo -e "\e[1;32mToken valid, melanjutkan ke instalasi.\e[0m"
}

# Fungsi untuk clear chat
clear_chat() {
    clear
    big_text
}

# Fungsi untuk instalasi phpMyAdmin
install_phpmyadmin() {
    read -p "Masukkan domain untuk phpMyAdmin: " domainphp

    echo -e "\e[1;33mMenginstal phpMyAdmin...\e[0m"
    
    # Install phpMyAdmin
    mkdir -p /var/www/phpmyadmin && mkdir /var/www/phpmyadmin/tmp/
    cd /var/www/phpmyadmin
    wget https://www.phpmyadmin.net/downloads/phpMyAdmin-latest-english.tar.gz
    tar xvzf phpMyAdmin-latest-english.tar.gz
    mv /var/www/phpmyadmin/phpMyAdmin--english/ /var/www/phpMyAdmin

    # Konfigurasi SSL
    certbot certonly --nginx -d $domainphp

    # Set permissions
    chown -R www-data:www-data /var/www/phpmyadmin
    chmod o+rw /var/www/phpmyadmin/config
    cp /var/www/phpmyadmin/config.sample.inc.php /var/www/phpmyadmin/config/config.inc.php
    chmod o+w /var/www/phpmyadmin/config/config.inc.php

    # Buat file konfigurasi nginx untuk phpMyAdmin
    cat <<EOL > /etc/nginx/sites-available/phpmyadmin.conf
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

    client_max_body_size 100m;
    client_body_timeout 120s;
    sendfile off;

    ssl_certificate /etc/letsencrypt/live/$domainphp/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/$domainphp/privkey.pem;
    ssl_session_cache shared:SSL:10m;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers 'ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384';

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location ~ \.php$ {
        fastcgi_pass unix:/run/php/php8.1-fpm.sock;
        fastcgi_index index.php;
        include fastcgi_params;
    }
}
EOL

    # Aktifkan konfigurasi nginx untuk phpMyAdmin
    ln -s /etc/nginx/sites-available/phpmyadmin.conf /etc/nginx/sites-enabled/

    # Restart nginx
    systemctl restart nginx

    echo -e "\e[1;32mphpMyAdmin berhasil diinstal dan diaktifkan.\e[0m"
}

# Fungsi untuk create database
create_database() {
    read -p "Masukkan username database: " dbuser
    read -p "Masukkan IP database: " ipdb
    read -p "Masukkan password database: " pwdb

    echo -e "\e[1;33mMembuat database...\e[0m"

    mysql -u root -p -e "CREATE USER '$dbuser'@'$ipdb' IDENTIFIED BY '$pwdb';"
    mysql -u root -p -e "GRANT ALL PRIVILEGES ON *.* TO '$dbuser'@'$ipdb' WITH GRANT OPTION;"

    echo -e "\e[1;32mDatabase dan user berhasil dibuat.\e[0m"
}

# Fungsi untuk uninstal phpMyAdmin
uninstall_phpmyadmin() {
    read -p "Masukkan domain phpMyAdmin untuk dihapus: " domainphp

    echo -e "\e[1;33mMenghapus phpMyAdmin...\e[0m"

    # Hapus konfigurasi phpMyAdmin di Nginx
    rm /etc/nginx/sites-enabled/phpmyadmin.conf
    rm /etc/nginx/sites-available/phpmyadmin.conf

    # Hapus folder phpMyAdmin
    rm -rf /var/www/phpmyadmin

    # Restart nginx
    systemctl restart nginx

    echo -e "\e[1;32mphpMyAdmin berhasil dihapus.\e[0m"
}

# Menu Pilihan
menu() {
    clear_chat
    echo -e "\e[1;34mAUTO INSTALLER BY FAJAR OFFICIAL\e[0m"
    echo -e "\e[1;32mSilakan pilih:\e[0m"
    echo "1) Instal phpMyAdmin"
    echo "2) Buat Database"
    echo "3) Uninstal phpMyAdmin"
    echo "4) Keluar"

    read -p "Pilihan (1/2/3/4): " pilihan

    case $pilihan in
        1)
            install_phpmyadmin
            ;;
        2)
            create_database
            ;;
        3)
            uninstall_phpmyadmin
            ;;
        4)
            echo -e "\e[1;32mTerima kasih sudah menggunakan Auto Installer by Fajar Official.\e[0m"
            exit 0
            ;;
        *)
            echo -e "\e[1;31mPilihan tidak valid. Silakan coba lagi.\e[0m"
            menu
            ;;
    esac
}

# Main Script
clear_chat
big_text
verify_token
menu
