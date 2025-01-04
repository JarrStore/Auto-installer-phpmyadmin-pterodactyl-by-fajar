#!/bin/bash

# Meminta input domain
read -p "Masukkan domain tanpa https://: " DOMAIN

# Memastikan domain tidak kosong
if [ -z "$DOMAIN" ]; then
  echo "Domain tidak boleh kosong."
  exit 1
fi

# Menghapus sertifikat SSL dari Let's Encrypt
echo "Menghapus sertifikat SSL untuk domain $DOMAIN..."
rm -rf /etc/letsencrypt/live/$DOMAIN
rm -rf /etc/letsencrypt/archive/$DOMAIN
rm -rf /etc/letsencrypt/renewal/$DOMAIN.conf

# Mengecek apakah penghapusan berhasil
if [ ! -d "/etc/letsencrypt/live/$DOMAIN" ] && [ ! -d "/etc/letsencrypt/archive/$DOMAIN" ] && [ ! -f "/etc/letsencrypt/renewal/$DOMAIN.conf" ]; then
  echo "Sukses menghapus SSL untuk domain $DOMAIN."
else
  echo "Gagal menghapus SSL untuk domain $DOMAIN. Pastikan Anda menjalankan script ini dengan akses root."
fi

# Keluar
exit 0
