#!/bin/bash

# Define database credentials
DB_HOST="178.128.17.191"
DB_USERNAME="u5_IswvFa3OCO"
DB_PASSWORD="0!^quZYF8FRIEPM5qEb^YPuP"
DB_NAME="s5_tokenbash"

# Function to display welcome message
welcome_message() {
    clear
    echo -e "\e[1;32m#########################################################\e[0m"
    echo -e "\e[1;36mSELAMAT DATANG AUTO INSTALLER BY FAJAR OFFICIAL\e[0m"
    echo -e "\e[1;36mSilahkan masukkan token\e[0m"
    echo -e "\e[1;32m#########################################################\e[0m"
}

# Function to validate token in the database
validate_token() {
    read -p "Masukkan token: " user_token
    TOKEN_EXISTS=$(mysql -h $DB_HOST -u $DB_USERNAME -p$DB_PASSWORD -D $DB_NAME -sse "SELECT EXISTS(SELECT 1 FROM tokens WHERE token='$user_token')")

    if [ "$TOKEN_EXISTS" != 1 ]; then
        echo -e "\e[1;31mToken salah, instalasi dibatalkan.\e[0m"
        exit 1
    fi
}

# Function for phpMyAdmin installation
install_phpmyadmin() {
    echo -e "\e[1;32mMemulai instalasi phpMyAdmin...\e[0m"
    read -p "Apakah Anda yakin untuk menginstal phpMyAdmin? (y/n): " confirm
    if [[ "$confirm" != "y" ]]; then
        echo -e "\e[1;31mInstalasi dibatalkan.\e[0m"
        return
    fi

    echo -e "\e[1;32mMenyiapkan direktori untuk phpMyAdmin...\e[0m"
    mkdir -p /var/www/phpmyadmin && mkdir -p /var/www/phpmyadmin/tmp/ && cd /var/www/phpmyadmin

    echo -e "\e[1;32mMengunduh phpMyAdmin...\e[0m"
    wget https://www.phpmyadmin.net/downloads/phpMyAdmin-latest-english.tar.gz
    tar xvzf phpMyAdmin-latest-english.tar.gz
    mv /var/www/phpmyadmin/phpMyAdmin-*-english/* /var/www/phpmyadmin

    echo -e "\e[1;32mMenyiapkan konfigurasi...\e[0m"
    chown -R www-data:www-data *
    mkdir config
    chmod o+rw config
    cp config.sample.inc.php config/config.inc.php
    chmod o+w config/config.inc.php

    echo -e "\e[1;32mMembuat sertifikat SSL...\e[0m"
    read -p "Masukkan domain untuk sertifikat SSL: " domain
    certbot certonly --nginx -d $domain

    echo -e "\e[1;32mMengonfigurasi server web...\e[0m"
    cat > /etc/nginx/sites-available/phpmyadmin.conf <<EOL
server {
    listen 80;
    server_name $domain;
    return 301 https://\$server_name\$request_uri;
}

server {
    listen 443 ssl http2;
    server_name $domain;

    root /var/www/phpmyadmin;
    index index.php;

    client_max_body_size 100m;
    client_body_timeout 120s;

    sendfile off;

    ssl_certificate /etc/letsencrypt/live/$domain/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/$domain/privkey.pem;
    ssl_session_cache shared:SSL:10m;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers 'ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256';
    ssl_prefer_server_ciphers on;

    add_header X-Content-Type-Options nosniff;
    add_header X-XSS-Protection "1; mode=block";
    add_header X-Robots-Tag none;
    add_header Content-Security-Policy "frame-ancestors 'self'";
    add_header X-Frame-Options DENY;

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location ~ \.php$ {
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        fastcgi_pass unix:/run/php/php8.1-fpm.sock;
        fastcgi_index index.php;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
    }
}
EOL

    ln -s /etc/nginx/sites-available/phpmyadmin.conf /etc/nginx/sites-enabled/phpmyadmin.conf
    systemctl restart nginx

    echo -e "\e[1;32mphpMyAdmin berhasil diinstal dan dikonfigurasi!\e[0m"
    echo -e "\e[1;32mTERIMAKASIH SUDAH PAKAI AUTO INSTALLER PHPMYADMIN BY FAJAR OFFICIAL\e[0m"
}

# Function to create a database
create_database() {
    echo -e "\e[1;32mMembuat database baru...\e[0m"
    read -p "Masukkan username database: " dbuser
    read -p "Masukkan IP database: " ipdb
    read -p "Masukkan password database: " pwdb

    echo -e "\e[1;32mMembuat user dan memberikan hak akses...\e[0m"
    mysql -u root -p -e "CREATE USER '$dbuser'@'$ipdb' IDENTIFIED BY '$pwdb';"
    mysql -u root -p -e "GRANT ALL PRIVILEGES ON *.* TO '$dbuser'@'$ipdb' WITH GRANT OPTION;"

    echo -e "\e[1;32mDATABASE SUDAH DI BUAT BY FAJAR OFFC YAITU $dbuser@'$ipdb'\e[0m"
}

# Main Menu
while true; do
    welcome_message
    echo -e "\e[1;32mAUTO INSTALLER BY FAJAR OFFICIAL\e[0m"
    echo -e "\e[1;33mSilahkan pilih:\e[0m"
    echo -e "\e[1;34m1. Instal phpMyAdmin\e[0m"
    echo -e "\e[1;34m2. Buat Database\e[0m"
    echo -e "\e[1;34m3. Keluar\e[0m"
    read -p "Pilihan (1/2/3): " choice

    case $choice in
        1)
            install_phpmyadmin
            ;;
        2)
            create_database
            ;;
        3)
            echo -e "\e[1;32mTerimakasih telah menggunakan Auto Installer! Sampai jumpa!\e[0m"
            break
            ;;
        *)
            echo -e "\e[1;31mPilihan tidak valid! Silakan coba lagi.\e[0m"
            ;;
    esac
done
