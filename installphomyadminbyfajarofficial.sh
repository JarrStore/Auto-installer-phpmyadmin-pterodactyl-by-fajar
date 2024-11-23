#!/bin/bash

# Database connection details
DB_HOST="178.128.17.191"
DB_USERNAME="u5_IswvFa3OCO"
DB_PASSWORD="0!^quZYF8FRIEPM5qEb^YPuP"
DB_NAME="s5_tokenbash"

# Display Welcome Message with Color
clear
echo -e "\e[1;32m
###########################################################
#   SELAMAT DATANG AUTO INSTALLER BY FAJAR OFFICIAL     #
#        Silahkan masukan token untuk melanjutkan       #
###########################################################
\e[0m"

# Ask for token
read -p "Masukkan token: " user_token

# Check if the token exists in the database
TOKEN_EXISTS=$(mysql -h $DB_HOST -u $DB_USERNAME -p$DB_PASSWORD -D $DB_NAME -sse "SELECT EXISTS(SELECT 1 FROM tokens WHERE token='$user_token')")

if [ "$TOKEN_EXISTS" != 1 ]; then
  echo -e "\e[1;31mToken salah, instalasi dibatalkan.\e[0m"
  exit 1
fi

# Main Installer Menu
while true; do
  clear
  echo -e "\e[1;32m
###########################################################
#    AUTO INSTALLER BY FAJAR OFFICIAL                    #
#    Silahkan pilih menu berikut:                        #
#    1. Instal phpMyAdmin                               #
#    2. Create Database                                  #
#    3. Exit                                             #
###########################################################
\e[0m"
  
  read -p "Pilih menu (1/2/3): " choice

  case $choice in
    1)
      # Install phpMyAdmin
      read -p "Masukkan domain PHPMyAdmin: " domainphp
      read -p "Apakah Anda yakin ingin menginstall phpMyAdmin di $domainphp? (y/n): " confirm
      if [ "$confirm" != "y" ]; then
        echo "Instalasi dibatalkan."
        continue
      fi

      echo "Memulai instalasi phpMyAdmin..."

      # Installation steps for phpMyAdmin
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

      # Create SSL Certificates
      certbot certonly --nginx -d $domainphp

      # Web Server Configuration
      cat > /etc/nginx/sites-available/phpmyadmin.conf <<EOF
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
    ssl_ciphers 'ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305';
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

    location ~ \.php$ {
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
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
    }

    location ~ /\.ht {
        deny all;
    }
}
EOF

      # Applying Configuration
      sudo ln -s /etc/nginx/sites-available/phpmyadmin.conf /etc/nginx/sites-enabled/phpmyadmin.conf
      systemctl restart nginx

      echo -e "\e[1;32mTerimakasih sudah memakai Auto Installer phpMyAdmin by Fajar Official.\e[0m"
      ;;
    2)
      # Create Database
      read -p "Masukkan nama pengguna DB: " dbuser
      read -p "Masukkan IP database: " ipdb
      read -p "Masukkan password DB: " pwdb
      read -p "Apakah Anda yakin ingin membuat database dengan pengguna $dbuser di IP $ipdb? (y/n): " confirm
      if [ "$confirm" != "y" ]; then
        echo "Proses dibatalkan."
        continue
      fi

      # Database creation
      mysql -h $DB_HOST -u $DB_USERNAME -p$DB_PASSWORD -e "CREATE USER '$dbuser'@'$ipdb' IDENTIFIED BY '$pwdb';"
      mysql -h $DB_HOST -u $DB_USERNAME -p$DB_PASSWORD -e "GRANT ALL PRIVILEGES ON *.* TO '$dbuser'@'$ipdb' WITH GRANT OPTION;"
      mysql -h $DB_HOST -u $DB_USERNAME -p$DB_PASSWORD -e "FLUSH PRIVILEGES;"

      echo -e "\e[1;32mDATABASE SUDAH DI BUAT BY FAJAR OFFICIAL!\e[0m"
      ;;
    3)
      echo "Keluar dari Auto Installer."
      break
      ;;
    *)
      echo "Pilihan tidak valid. Silakan pilih lagi."
      ;;
  esac
done