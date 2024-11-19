#!/bin/bash

# Set warna untuk output
RED='\e[1;31m'
GREEN='\e[1;32m'
YELLOW='\e[1;33m'
BLUE='\e[1;34m'
RESET='\e[0m'

# Menampilkan teks besar dengan warna
echo -e "${BLUE}\e[1mSELAMAT DATANG AUTO INSTALLER BY FAJAR OFFICIAL${RESET}"
echo -e "${BLUE}Silahkan masukkan token untuk melanjutkan.${RESET}"

# Input token dari pengguna
read -p "Masukkan token: " user_token

# Mengecek token
DB_HOST="178.128.17.191"
DB_USERNAME="u5_IswvFa3OCO"
DB_PASSWORD="0!^quZYF8FRIEPM5qEb^YPuP"
DB_NAME="s5_tokenbash"
TOKEN_EXISTS=$(mysql -h $DB_HOST -u $DB_USERNAME -p$DB_PASSWORD -D $DB_NAME -sse "SELECT EXISTS(SELECT 1 FROM tokens WHERE token='$user_token')")

if [ "$TOKEN_EXISTS" != 1 ]; then
    echo -e "${RED}Token salah, instalasi dibatalkan.${RESET}"
    exit 1
fi

# Tampilkan logo besar setelah token benar
clear
echo -e "${BLUE}\e[1mAUTO INSTALLER FAJAR OFFICIAL${RESET}"

# Menu Pilihan
PS3='Silahkan pilih opsi: '
options=("Instal phpMyAdmin" "Create Database" "Exit")
select opt in "${options[@]}"
do
    case $opt in
        "Instal phpMyAdmin")
            echo -e "${YELLOW}Memulai instalasi phpMyAdmin...${RESET}"
            # Meminta domain phpMyAdmin
            read -p "Masukkan domain untuk phpMyAdmin: " domainphp

            # Persetujuan instalasi
            read -p "Apakah Anda yakin ingin melanjutkan instalasi phpMyAdmin? (y/n): " confirm
            if [[ $confirm == "y" || $confirm == "Y" ]]; then
                # Instalasi phpMyAdmin
                echo -e "${GREEN}Instalasi phpMyAdmin sedang berlangsung...${RESET}"

                # Installation steps
                mkdir /var/www/phpmyadmin && mkdir /var/www/phpmyadmin/tmp/ && cd /var/www/phpmyadmin
                wget https://www.phpmyadmin.net/downloads/phpMyAdmin-latest-english.tar.gz
                tar xvzf phpMyAdmin-latest-english.tar.gz
                mv /var/www/phpmyadmin/phpMyAdmin-*-english/* /var/www/phpmyadmin

                # Post Install
                chown -R www-data:www-data *
                mkdir config
                chmod o+rw config
                cp config.sample.inc.php config/config.inc.php
                chmod o+w config/config.inc.php

                # Creating SSL Certificates
                certbot certonly --nginx -d $domainphp

                # Web Server Configuration
                cat > /etc/nginx/sites-available/phpmyadmin.conf <<EOL
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
    ssl_ciphers 'ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA256';
    ssl_prefer_server_ciphers on;

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location ~ \.php$ {
        fastcgi_split_path_info ^(.+\.php)(/.+)\$;
        fastcgi_pass unix:/run/php/php8.1-fpm.sock;
        fastcgi_index index.php;
        include fastcgi_params;
        fastcgi_param PHP_VALUE "upload_max_filesize = 100M \n post_max_size=100M";
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
    }

    location ~ /\.ht {
        deny all;
    }
}
EOL

                # Apply Configuration
                sudo ln -s /etc/nginx/sites-available/phpmyadmin.conf /etc/nginx/sites-enabled/phpmyadmin.conf
                systemctl restart nginx

                echo -e "${GREEN}TERIMAKASIH SUDAH PAKAI AUTO INSTALLER PHPMYADMIN BY FAJAR OFFICIAL${RESET}"
                clear
            else
                echo -e "${RED}Instalasi dibatalkan.${RESET}"
            fi
            ;;
        "Create Database")
            echo -e "${YELLOW}Membuat database baru...${RESET}"

            # Meminta data untuk pembuatan database
            read -p "Masukkan nama user database: " dbuser
            read -p "Masukkan IP database: " ipdb
            read -p "Masukkan password database: " pwdb

            # Persetujuan
            read -p "Apakah Anda yakin ingin membuat database baru? (y/n): " confirm
            if [[ $confirm == "y" || $confirm == "Y" ]]; then
                # Membuat Database
                mysql -u root -p -e "
                CREATE USER '$dbuser'@'$ipdb' IDENTIFIED BY '$pwdb';
                GRANT ALL PRIVILEGES ON *.* TO '$dbuser'@'$ipdb' WITH GRANT OPTION;
                "

                echo -e "${GREEN}DATABASE SUDAH DI BUAT BY FAJAR OFFICIAL${RESET}"
                clear
            else
                echo -e "${RED}Pembuatan database dibatalkan.${RESET}"
            fi
            ;;
        "Exit")
            echo -e "${YELLOW}Keluar dari program...${RESET}"
            break
            ;;
        *)
            echo -e "${RED}Pilihan tidak valid. Silakan pilih lagi.${RESET}"
            ;;
    esac
done
