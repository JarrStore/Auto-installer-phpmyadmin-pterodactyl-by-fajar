#!/bin/bash

# Pastikan untuk menjalankan script ini dengan hak akses sudo atau root

echo "### Script Uninstall phpMyAdmin ###"
echo "Masukkan domain yang digunakan oleh phpMyAdmin:"
read DOMAIN

# Validasi input domain
if [ -z "$DOMAIN" ]; then
    echo "Domain tidak boleh kosong. Script dihentikan."
    exit 1
fi

echo "Domain yang Anda masukkan: $DOMAIN"

# Menghapus phpMyAdmin dari direktori /var/www
echo "Menghapus phpMyAdmin dari /var/www"
rm -rf /var/www/phpmyadmin

# Menghapus file konfigurasi Nginx untuk phpMyAdmin
echo "Menghapus konfigurasi Nginx phpMyAdmin"
rm -f /etc/nginx/sites-available/phpmyadmin.conf
rm -f /etc/nginx/sites-enabled/phpmyadmin.conf

# Menghapus sertifikat SSL dari Let's Encrypt untuk domain phpMyAdmin
echo "Menghapus sertifikat SSL untuk domain $DOMAIN"
rm -rf /etc/letsencrypt/live/$DOMAIN
rm -rf /etc/letsencrypt/archive/$DOMAIN
rm -rf /etc/letsencrypt/renewal/$DOMAIN.conf

# Menghapus file konfigurasi phpMyAdmin (jika ada)
echo "Menghapus file konfigurasi phpMyAdmin"
rm -f /var/www/phpmyadmin/config/config.inc.php

# Menghapus file sample konfigurasi phpMyAdmin (jika ada)
echo "Menghapus file sample konfigurasi phpMyAdmin"
rm -f /var/www/phpmyadmin/config.sample.inc.php

# Menghapus direktori sementara phpMyAdmin
echo "Menghapus direktori sementara phpMyAdmin"
rm -rf /var/www/phpmyadmin/tmp/

# Menghapus file konfigurasi Nginx untuk phpMyAdmin
echo "Menghapus konfigurasi phpMyAdmin di Nginx"
rm -f /etc/nginx/sites-available/phpmyadmin.conf
rm -f /etc/nginx/sites-enabled/phpmyadmin.conf

# Restart Nginx untuk menerapkan perubahan
echo "Restart Nginx untuk menerapkan perubahan"
systemctl restart nginx

echo "Uninstall phpMyAdmin selesai."
