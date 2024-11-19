p#!/bin/bash

# Warna teks
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
RESET='\033[0m'

# Menampilkan pesan besar dengan warna
echo -e "${BLUE}"
echo "##########################################"
echo "##                                      ##"
echo "##       AUTO INSTALLER BY FAJAR        ##"
echo "##            OFFICIAL                  ##"
echo "##                                      ##"
echo "##########################################"
echo -e "${RESET}"

# Verifikasi Token
EXPECTED_TOKEN="fajaroffc"
echo -e "${YELLOW}Masukkan token Anda: ${RESET}"
read -p "Token: " user_token

# Memeriksa token di database
DB_HOST="178.128.17.191"
DB_USERNAME="u5_IswvFa3OCO"
DB_PASSWORD="0!^quZYF8FRIEPM5qEb^YPuP"
DB_NAME="s5_tokenbash"

TOKEN_EXISTS=$(mysql -h $DB_HOST -u $DB_USERNAME -p$DB_PASSWORD -D $DB_NAME -sse "SELECT EXISTS(SELECT 1 FROM tokens WHERE token='$user_token')")

if [ "$TOKEN_EXISTS" != 1 ]; then
    echo -e "${RED}Token salah, instalasi dibatalkan.${RESET}"
    exit 1
else
    echo -e "${GREEN}Token valid, instalasi dapat dilanjutkan!${RESET}"
fi

# Menampilkan Menu Pilihan
clear
echo -e "${CYAN}"
echo "##########################################"
echo "##                                      ##"
echo "##    AUTO INSTALLER BY FAJAR OFFICIAL   ##"
echo "##                                      ##"
echo "##########################################"
echo -e "${RESET}"
echo "Silakan pilih salah satu opsi:"
echo "1. Instal phpMyAdmin"
echo "2. Buat Database"
echo "3. Exit"
read -p "Masukkan pilihan [1/2/3]: " choice

case $choice in
    1)
        # Install phpMyAdmin
        echo -e "${MAGENTA}Memulai instalasi phpMyAdmin...${RESET}"
        read -p "Masukkan domain phpMyAdmin (contoh: domainphp.com): " domainphp
        echo -e "${CYAN}Memasang phpMyAdmin pada domain: $domainphp${RESET}"
        
        # Install phpMyAdmin
        mkdir /var/www/phpmyadmin && cd /var/www/phpMyAdmin
        wget https://www.phpmyadmin.net/downloads/phpMyAdmin-latest-english.tar.gz
        tar xvzf phpMyAdmin-latest-english.tar.gz
        mv /var/www/phpmyadmin/phpMyAdmin-*-english/* /var/www/phpMyAdmin
        sudo chown -R www-data:www-data /var/www/phpmyadmin
        sudo chmod o+rw /var/www/phpmyadmin/config
        sudo cp /var/www/phpmyadmin/config.sample.inc.php /var/www/phpmyadmin/config/config.inc.php
        sudo chmod o+w /var/www/phpmyadmin/config/config.inc.php
        echo -e "${GREEN}phpMyAdmin berhasil dipasang.${RESET}"

        # Membuat Sertifikat SSL
        certbot certonly --nginx -d ${domainphp}
        echo -e "${GREEN}Sertifikat SSL dibuat untuk ${domainphp}.${RESET}"

        # Konfigurasi Nginx untuk phpMyAdmin
        cat > /etc/nginx/sites-available/phpmyadmin.conf <<EOL
server {
    listen 80;
    server_name ${domainphp};
    return 301 https://\$server_name\$request_uri;
}

server {
    listen 443 ssl http2;
    server_name ${domainphp};

    root /var/www/phpmyadmin;
    index index.php;

    # Allow larger file uploads and longer script runtimes
    client_max_body_size 100m;
    client_body_timeout 120s;

    sendfile off;

    # SSL Configuration
    ssl_certificate /etc/letsencrypt/live/${domainphp}/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/${domainphp}/privkey.pem;
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
EOL

        # Mengaktifkan situs dan restart Nginx
        ln -s /etc/nginx/sites-available/phpmyadmin.conf /etc/nginx/sites-enabled/phpmyadmin.conf
        systemctl restart nginx
        echo -e "${GREEN}phpMyAdmin berhasil dipasang dan dapat diakses di https://${domainphp}${RESET}"
        echo -e "${MAGENTA}TERIMAKASIH SUDAH PAKAI AUTO INSTALLER PHPMYADMIN BY FAJAR OFFICIAL${RESET}"
        ;;

    2)
        # Membuat database
        echo -e "${MAGENTA}Buat Database Otomatis${RESET}"
        read -p "Masukkan nama pengguna database: " DB_USER
        read -p "Masukkan IP database: " IP_DB
        read -p "Masukkan kata sandi database: " PW_DB

        echo -e "${CYAN}Membuat pengguna dan database baru...${RESET}"
        mysql -u root -p <<MYSQL_SCRIPT
CREATE USER '${DB_USER}'@'${IP_DB}' IDENTIFIED BY '${PW_DB}';
CREATE DATABASE ${DB_USER}_db;
GRANT ALL PRIVILEGES ON ${DB_USER}_db.* TO '${DB_USER}'@'${IP_DB}';
FLUSH PRIVILEGES;
MYSQL_SCRIPT

        echo -e "${GREEN}Database dan pengguna berhasil dibuat.${RESET}"
        echo -e "${MAGENTA}DATABASE SUDAH DI BUAT BY FAJAR OFFC YAITU${RESET}"
        ;;

    3)
        echo -e "${CYAN}Keluar dari Auto Installer.${RESET}"
        exit 0
        ;;

    *)
        echo -e "${RED}Pilihan tidak valid.${RESET}"
        exit 1
        ;;
esac

# Kembali ke menu utama setelah selesai
clear
bash $0
