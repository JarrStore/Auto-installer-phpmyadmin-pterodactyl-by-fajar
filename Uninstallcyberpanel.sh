#!/bin/bash

# Fungsi untuk meminta input domain
read -p "Masukkan domain yang ingin dihapus SSL-nya: " domain

# Pastikan pengguna memasukkan domain
if [ -z "$domain" ]; then
    echo "Domain tidak boleh kosong. Skrip dibatalkan."
    exit 1
fi

# Menghentikan layanan CyberPanel
echo "Menghentikan layanan CyberPanel..."
systemctl stop lscpd
systemctl stop cyberpanel

# Menghapus CyberPanel
echo "Menghapus CyberPanel..."
cd /usr/local/CyberCP
./uninstall.py

# Menghapus SSL untuk domain
echo "Menghapus SSL untuk domain $domain..."
rm -rf /etc/letsencrypt/live/$domain
rm -rf /etc/letsencrypt/archive/$domain
rm -rf /etc/letsencrypt/renewal/$domain.conf

# Menghapus SSL certbot
echo "Menghapus certbot..."
apt-get remove --purge -y certbot

# Menghapus file konfigurasi CyberPanel
echo "Menghapus file konfigurasi CyberPanel..."
rm -rf /etc/cyberpanel

# Menghapus sisa-sisa file CyberPanel
echo "Menghapus sisa-sisa file CyberPanel..."
rm -rf /usr/local/CyberCP

# Menghapus user CyberPanel
echo "Menghapus user CyberPanel..."
deluser cyberpanel

# Membersihkan paket-paket yang tidak dibutuhkan
echo "Membersihkan paket yang tidak dibutuhkan..."
apt-get autoremove -y
apt-get clean

# Restart server untuk memastikan perubahan
echo "Proses uninstall selesai. Restart server untuk memastikan semua perubahan diterapkan."
echo "Silakan restart server Anda."

exit 0
