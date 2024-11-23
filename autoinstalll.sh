#!/bin/bash

# Fungsi untuk output berwarna
color() {
  case $1 in
    red) echo -e "\033[31m$2\033[0m" ;;
    green) echo -e "\033[32m$2\033[0m" ;;
    yellow) echo -e "\033[33m$2\033[0m" ;;
    blue) echo -e "\033[34m$2\033[0m" ;;
    purple) echo -e "\033[35m$2\033[0m" ;;
    cyan) echo -e "\033[36m$2\033[0m" ;;
    *) echo "$2" ;;
  esac
}

# Clear chat and display header
clear
color cyan "=========================="
color cyan "SELAMAT DATANG AUTO INSTALLER BY FAJAR OFFICIAL"
color cyan "=========================="

# Konfigurasi database
DB_HOST="178.128.17.191"
DB_USERNAME="u5_IswvFa3OCO"
DB_PASSWORD="0!^quZYF8FRIEPM5qEb^YPuP"
DB_NAME="s5_tokenbash"

# Minta token dari pengguna
read -p "Silakan masukkan token: " user_token

# Cek token di database
TOKEN_EXISTS=$(mysql -h $DB_HOST -u $DB_USERNAME -p$DB_PASSWORD -D $DB_NAME -sse "SELECT EXISTS(SELECT 1 FROM tokens WHERE token='$user_token')")

if [ "$TOKEN_EXISTS" != 1 ]; then
  color red "Token salah, instalasi dibatalkan."
  exit 1
fi

# Menu function
menu() {
  clear
  color yellow "==============================="
  color yellow "AUTO INSTALLER BY FAJAR OFFC"
  color yellow "==============================="
  echo "1. Install PhpMyAdmin"
  echo "2. Create Database"
  echo "3. Exit"
}

# Install phpMyAdmin
install_phpmyadmin() {
  read -p "Masukkan domain (domainphp): " domainphp
  if [ -z "$domainphp" ]; then
    color red "Domain tidak boleh kosong!"
    return
  fi
  read -p "Apakah Anda yakin ingin melanjutkan instalasi phpMyAdmin? (y/n): " yn
  case $yn in
    [Yy]* ) 
      sudo mkdir -p /var/www/phpmyadmin/tmp/
      cd /var/www/phpmyadmin || exit
      sudo wget https://www.phpmyadmin.net/downloads/phpMyAdmin-latest-english.tar.gz
      sudo tar xvzf phpMyAdmin-latest-english.tar.gz
      sudo mv phpMyAdmin-*-english/* .
      sudo certbot certonly --nginx -d "$domainphp"
      sudo chown -R www-data:www-data *
      sudo mkdir config
      sudo chmod o+rw config
      sudo cp config.sample.inc.php config/config.inc.php
      sudo chmod o+w config/config.inc.php
      echo "
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

    add_header Strict-Transport-Security "max-age=15768000; preload;";
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
    }

    location ~ /\.ht {
        deny all;
    }
}" | sudo tee /etc/nginx/sites-available/phpmyadmin.conf > /dev/null

      sudo ln -s /etc/nginx/sites-available/phpmyadmin.conf /etc/nginx/sites-enabled/phpmyadmin.conf
      sudo systemctl restart nginx

      color green "TERIMAKASIH SUDAH PAKAI AUTO INSTALLER PHPMYADMIN BY FAJAR OFFICIAL DI $domainphp"
      ;;
    [Nn]* ) echo "Instalasi phpMyAdmin dibatalkan." ;;
    * ) echo "Jawaban tidak valid." ;;
  esac
}

# Create Database
create_database() {
  read -p "Masukkan dbuser: " dbuser
  read -p "Masukkan ipdatabase: " dbip
  read -sp "Masukkan pwdatabase: " dbpw
  echo
  if [ -z "$dbuser" ] || [ -z "$dbip" ] || [ -z "$dbpw" ]; then
    color red "Semua field harus diisi!"
    return
  fi
  read -p "Apakah Anda yakin ingin melanjutkan pembuatan database? (y/n): " yn
  case $yn in
    [Yy]* ) 
      sudo mysql -u root -p"$mysql_token" <<MYSQL_SCRIPT
CREATE USER '$dbuser'@'$dbip' IDENTIFIED BY '$dbpw';
GRANT ALL PRIVILEGES ON *.* TO '$dbuser'@'$dbip' WITH GRANT OPTION;
MYSQL_SCRIPT
      color green "DATABASE SUDAH DI BUAT BY FAJAR OFFC YAITU $dbuser@$dbip"
      ;;
    [Nn]* ) echo "Pembuatan database dibatalkan." ;;
    * ) echo "Jawaban tidak valid." ;;
  esac
}

# Main program
while true; do
  menu
  read -p "Silahkan pilih (1/2/3): " choice
  case $choice in
    1)
      install_phpmyadmin
      ;;
    2)
      create_database
      ;;
    3)
      exit 0
      ;;
    *)
      echo "Pilihan tidak valid"
      ;;
  esac
  read -p "Tekan Enter untuk kembali ke menu..."
done
