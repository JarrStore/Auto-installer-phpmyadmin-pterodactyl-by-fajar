#!/bin/bash

# Function to print large colored text
print_large_text() {
    echo -e "\e[1;32m$1\e[0m"
}

# Function to print normal text with color
print_text() {
    echo -e "\e[1;34m$1\e[0m"
}

# Prompt for Token and Validate
clear
print_large_text "SELAMAT DATANG AUTO INSTALLER BY FAJAR OFFICIAL"
print_text "Silahkan masukkan token:"

read -p "Token: " user_token

# Database credentials
DB_HOST="178.128.17.191"
DB_USERNAME="u5_IswvFa3OCO"
DB_PASSWORD="0!^quZYF8FRIEPM5qEb^YPuP"
DB_NAME="s5_tokenbash"

# Check if the token exists in the database
TOKEN_EXISTS=$(mysql -h $DB_HOST -u $DB_USERNAME -p$DB_PASSWORD -D $DB_NAME -sse "SELECT EXISTS(SELECT 1 FROM tokens WHERE token='$user_token')")

if [ "$TOKEN_EXISTS" != 1 ]; then
    echo -e "\e[1;31mToken salah, instalasi dibatalkan.\e[0m"
    exit 1
fi

# If token is valid, proceed with installation
clear
print_large_text "AUTO INSTALLER FAJAR OFFICIAL"
print_text "Silahkan pilih opsi:"
echo "1) Install phpMyAdmin"
echo "2) Create Database"
echo "3) Exit"

read -p "Pilihan (1/2/3): " choice

# Install phpMyAdmin
if [ "$choice" -eq 1 ]; then
    read -p "Masukkan domain phpMyAdmin: " domainphp
    print_text "Apakah Anda ingin melanjutkan? (y/n)"
    read -p "Pilihan: " confirmation
    if [ "$confirmation" == "y" ]; then
        # Install phpMyAdmin
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
        cat <<EOF > /etc/nginx/sites-available/phpmyadmin.conf
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

    location ~ \\.php\$ {
        fastcgi_split_path_info ^(.+\\.php)(/.+)\$;
        fastcgi_pass unix:/run/php/php8.3-fpm.sock;
        fastcgi_index index.php;
        include fastcgi_params;
        fastcgi_param PHP_VALUE "upload_max_filesize = 100M \n post_max_size=100M";
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        fastcgi_param HTTP_PROXY "";
        fastcgi_intercept_errors off;
        fastcgi_buffer_size 16k;
        fastcgi_buffers 4 16k;
        fastcgi_connect_timeout 300;
        fastcgi_send_timeout 300;
        fastcgi_read_timeout 300;
        include /etc/nginx/fastcgi_params;
    }

    location ~ /\\.ht {
        deny all;
    }
}
EOF

        # Applying Configuration
        sudo ln -s /etc/nginx/sites-available/phpmyadmin.conf /etc/nginx/sites-enabled/phpmyadmin.conf
        systemctl restart nginx

        # SSL Configuration
        print_text "Terima kasih sudah menggunakan Auto Installer phpMyAdmin by Fajar Official"
        clear
    fi
elif [ "$choice" -eq 2 ]; then
    # Create Database
    read -p "Masukkan dbuser: " dbuser
    read -p "Masukkan IP DB: " ipdb
    read -p "Masukkan password DB: " pwdb
    print_text "Apakah Anda ingin melanjutkan? (y/n)"
    read -p "Pilihan: " confirmation
    if [ "$confirmation" == "y" ]; then
        # Creating MySQL Database User
        mysql -u root -p -e "CREATE USER '$dbuser'@'$ipdb' IDENTIFIED BY '$pwdb';"
        mysql -u root -p -e "GRANT ALL PRIVILEGES ON *.* TO '$dbuser'@'$ipdb' WITH GRANT OPTION;"
        print_text "DATABASE SUDAH DI BUAT BY FAJAR OFFICIAL"
        clear
    fi
elif [ "$choice" -eq 3 ]; then
    # Exit
    exit 0
else
    print_text "Pilihan tidak valid, keluar dari program."
    exit 1
fi
