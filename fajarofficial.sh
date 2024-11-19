#!/bin/bash

# Warna teks
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RESET='\033[0m'

# Menampilkan pesan besar dengan warna
echo -e "${BLUE}##########################################"
echo "##                                      ##"
echo "##       SELAMAT DATANG AUTO INSTALLER  ##"
echo "##         BY FAJAR OFFICIAL            ##"
echo "##                                      ##"
echo "##########################################"
echo -e "${RESET}"

# Verifikasi Token
read -p "Silahkan masukan token: " user_token

DB_HOST="178.128.17.191"
DB_USERNAME="u5_IswvFa3OCO"
DB_PASSWORD="0!^quZYF8FRIEPM5qEb^YPuP"
DB_NAME="s5_tokenbash"

TOKEN_EXISTS=$(mysql -h $DB_HOST -u $DB_USERNAME -p$DB_PASSWORD -D $DB_NAME -sse "SELECT EXISTS(SELECT 1 FROM tokens WHERE token='$user_token')")
if [ "$TOKEN_EXISTS" != 1 ]; then
    echo -e "${RED}Token salah, instalasi dibatalkan.${RESET}"
    exit 1
fi

echo -e "${GREEN}AUTO INSTALLER FAJAR OFFC${RESET}"

while true; do
    clear
    echo -e "${BLUE}AUTO INSTALLER BY FAJAR OFFICIAL${RESET}"
    echo "1. Install phpMyAdmin"
    echo "2. Create Database"
    echo "3. Uninstall phpMyAdmin"
    echo "4. Exit"
    read -p "Silahkan pilih: " choice
    
    case $choice in
        1)
            echo -e "${GREEN}Menginstall phpMyAdmin...${RESET}"
            mkdir /var/www/phpmyadmin && mkdir /var/www/phpmyadmin/tmp/ && cd /var/www/phpmyadmin
            wget https://www.phpmyadmin.net/downloads/phpMyAdmin-latest-english.tar.gz
            tar xvzf phpMyAdmin-latest-english.tar.gz
            mv /var/www/phpmyadmin/phpMyAdmin-*-english/* /var/www/phpmyadmin
            certbot certonly --nginx -d <domain>
            chown -R www-data:www-data * 
            mkdir config
            chmod o+rw config
            cp config.sample.inc.php config/config.inc.php
            chmod o+w config/config.inc.php
            nano /etc/nginx/sites-available/phpmyadmin.conf
            # Konfigurasi Web Server
            cat > /etc/nginx/sites-available/phpmyadmin.conf <<EOL
server {
    listen 80;
    server_name <domain>;
    return 301 https://\$server_name\$request_uri;
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
            ln -s /etc/nginx/sites-available/phpmyadmin.conf /etc/nginx/sites-enabled/phpmyadmin.conf
            systemctl restart nginx
            echo -e "${GREEN}phpMyAdmin selesai diinstal di domain.<domain>${RESET}"
            echo -e "${GREEN}TERIMAKASIH SUDAH PAKAI AUTO INSTALLER PHPMYADMIN BY FAJAR OFFICIAL${RESET}"
            ;;
        2)
            echo -e "${GREEN}Membuat Database...${RESET}"
            read -p "Masukkan nama pengguna database: " dbuser
            read -p "Masukkan IP database: " ipdb
            read -p "Masukkan password database: " pwdb
            mysql -u root -p <<MYSQL_SCRIPT
CREATE USER '$dbuser'@'$ipdb' IDENTIFIED BY '$pwdb';
GRANT ALL PRIVILEGES ON *.* TO '$dbuser'@'$ipdb' WITH GRANT OPTION;
MYSQL_SCRIPT
            echo -e "${GREEN}DATABASE SUDAH DI BUAT BY FAJAR OFFC${RESET}"
            ;;
        3)
            echo -e "${GREEN}Uninstall phpMyAdmin...${RESET}"
            read -p "Masukkan domain: " domainphp
            rm -rf /var/www/phpmyadmin
            certbot delete --cert-name $domainphp
            rm /etc/nginx/sites-available/phpmyadmin.conf
            rm /etc/nginx/sites-enabled/phpmyadmin.conf
            systemctl restart nginx
            echo -e "${GREEN}phpMyAdmin dan SSL untuk $domainphp sudah dihapus${RESET}"
            ;;
        4)
            echo -e "${GREEN}Keluar dari installer...${RESET}"
            exit 0
            ;;
        *)
            echo -e "${RED}Pilihan tidak valid.${RESET}"
            ;;
    esac
done
