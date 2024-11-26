#!/bin/bash

# Warna teks
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Koneksi database
DB_HOST="178.128.17.191"
DB_USERNAME="u5_IswvFa3OCO"
DB_PASSWORD="0!^quZYF8FRIEPM5qEb^YPuP"
DB_NAME="s5_tokenbash"

# Fungsi untuk menampilkan running text
show_running_text() {
    text="Selamat Datang SC Auto Installer by Fajar Official"
    tput civis  # Sembunyikan kursor
    while :; do
        for ((i = 0; i < ${#text}; i++)); do
            tput cup 0 $i
            echo -ne "${GREEN}${text:$i:1}${NC}"
            sleep 0.1
        done
    done
}

# Pesan selamat datang
clear
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  SELAMAT DATANG AUTO INSTALLER BY FAJAR OFFICIAL  ${NC}"
echo -e "${GREEN}========================================${NC}"
echo -e "Silahkan masukan token:"
read user_token

# Validasi token
TOKEN_EXISTS=$(mysql -h $DB_HOST -u $DB_USERNAME -p$DB_PASSWORD -D $DB_NAME -sse "SELECT EXISTS(SELECT 1 FROM tokens WHERE token='$user_token')")
if [ "$TOKEN_EXISTS" != 1 ]; then
    echo -e "${RED}Kode Salah Kocak Buy di wa.me/+6283157602477 no free update token 10k free update token 20k${NC}"
    exit 1
fi

# Tampilkan running text
show_running_text &

# Menu utama
while true; do
    clear
    echo -e "${YELLOW}========================================${NC}"
    echo -e "${YELLOW}  AUTO INSTALLER FAJAR OFFICIAL  ${NC}"
    echo -e "${YELLOW}========================================${NC}"
    echo -e "Silahkan pilih:"
    echo -e "1) Instal phpMyAdmin"
    echo -e "2) Create Database"
    echo -e "3) Uninstall phpMyAdmin"
    echo -e "4) Exit"
    read -p "Pilihan Anda: " choice

    case $choice in
        1)
            clear
            read -p "Masukkan domain untuk phpMyAdmin: " domainphp
            read -p "Apakah Anda yakin ingin menginstal phpMyAdmin? (y/n): " confirm
            if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
                # Instalasi phpMyAdmin
                mkdir -p /var/www/phpmyadmin/tmp/ && cd /var/www/phpmyadmin
                wget https://www.phpmyadmin.net/downloads/phpMyAdmin-latest-english.tar.gz
                tar xvzf phpMyAdmin-latest-english.tar.gz
                mv phpMyAdmin-*-english/* .
                rm -r phpMyAdmin-*-english

                # Post Install
                chown -R www-data:www-data *
                mkdir config
                chmod o+rw config
                cp config.sample.inc.php config/config.inc.php
                chmod o+w config/config.inc.php

                # Creating SSL Certificates
                certbot certonly --nginx -d $domainphp

                # Web Server Configuration
                cat <<EOT > /etc/nginx/sites-available/phpmyadmin.conf
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

    # allow larger file uploads and longer script runtimes
    client_max_body_size 100m;
    client_body_timeout 120s;

    sendfile off;

    # SSL Configuration
    ssl_certificate /etc/letsencrypt/live/$domainphp/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/$domainphp/privkey.pem;
    ssl_session_cache shared:SSL:10m;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers 'ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA256';
    ssl_prefer_server_ciphers on;

    add_header X-Content-Type-Options nosniff;
    add_header X-XSS-Protection "1; mode=block";
    add_header X-Robots-Tag none;
    add_header Content-Security-Policy "frame-ancestors 'self'";
    add_header X-Frame-Options DENY;
    add_header Referrer-Policy same-origin;

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location ~ \.php\$ {
        fastcgi_split_path_info ^(.+\.php)(/.+)\$;
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

    location ~ /\.ht {
        deny all;
    }
}
EOT

                # Applying Configuration
                sudo ln -s /etc/nginx/sites-available/phpmyadmin.conf /etc/nginx/sites-enabled/phpmyadmin.conf
                sudo systemctl restart nginx

                clear
                echo -e "${GREEN}TERIMAKASIH SUDAH PAKAI AUTO INSTALLER PHPMYADMIN BY FAJAR OFFICIAL${NC}"
            fi
            ;;
        2)
            clear
            read -p "Masukkan DB username: " dbuser
            read -p "Masukkan DB IP: " dbip
            read -p "Masukkan DB password: " dbpassword
            read -p "Apakah Anda yakin ingin membuat database? (y/n): " confirm
            if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
                mysql -u root -p -e "CREATE USER '$dbuser'@'$dbip' IDENTIFIED BY '$dbpassword'; GRANT ALL PRIVILEGES ON *.* TO '$dbuser'@'$dbip' WITH GRANT OPTION;"
                clear
                echo -e "${GREEN}DATABASE SUDAH DI BUAT BY FAJAR OFFC YAITU ${NC}"
            fi
            ;;
        3)
            clear
            read -p "Masukkan domain untuk uninstall phpMyAdmin: " domainphp
            read -p "Apakah Anda yakin ingin meng-uninstall phpMyAdmin? (y/n): " confirm
            if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
                sudo rm -rf /var/www/phpmyadmin
                sudo rm /etc/nginx/sites-available/phpmyadmin.conf
                sudo rm /etc/nginx/sites-enabled/phpmyadmin.conf
                sudo systemctl restart nginx
                clear
                echo -e "${GREEN}phpMyAdmin telah di-uninstall dari domain ${domainphp}${NC}"
            fi
            ;;
        4)
            exit 0
            ;;
        *)
            echo -e "${RED}Pilihan tidak valid!${NC}"
            ;;
    esac
done
