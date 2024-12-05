#!/bin/bash

# Hentikan layanan CyberPanel
echo "Menghentikan layanan CyberPanel..."
sudo systemctl stop lscpd
sudo systemctl stop lshttpd

# Hapus paket CyberPanel
echo "Menghapus paket CyberPanel..."
sudo apt-get purge -y cyberpanel
sudo apt-get autoremove -y

# Hapus direktori CyberPanel
echo "Menghapus direktori CyberPanel..."
sudo rm -rf /usr/local/CyberPanel
sudo rm -rf /usr/local/lsws

# Minta domain dari pengguna
read -p "Masukkan nama domain yang ingin dihapus SSL-nya: " domain

# Hapus SSL untuk domain tersebut
echo "Menghapus SSL untuk domain $domain..."
sudo rm -rf /etc/letsencrypt/live/$domain
sudo rm -rf /etc/letsencrypt/archive/$domain
sudo rm -rf /etc/letsencrypt/renewal/$domain.conf

# Hapus aturan firewall
echo "Menghapus aturan firewall..."
sudo ufw delete allow 8090/tcp

echo "Proses uninstall CyberPanel dan penghapusan SSL selesai."
