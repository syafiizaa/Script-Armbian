#!/bin/bash
# ============================================
# SETUP STB ARMBIAN SCRIPT
# VERSION: 2.3 (DOCKER SAFETY GUARDED)
# ============================================

ensure_docker() {
    if ! command -v docker >/dev/null 2>&1; then
        echo "Docker belum terpasang. Menginstall Docker..."
        sudo apt update
        sudo apt install -y docker.io
        sudo systemctl enable --now docker
    else
        echo "Docker sudah terpasang."
    fi

    if ! docker compose version >/dev/null 2>&1; then
        echo "Docker Compose belum terpasang. Menginstall..."
        sudo apt install -y docker-compose-plugin
    else
        echo "Docker Compose sudah tersedia."
    fi
}

while true; do
clear
echo "===================================="
echo "  MENU SETUP STB ARMBIAN (v2.3)"
echo "===================================="
echo ""
echo "  === SYSTEM ==="
echo "  1. Update & Upgrade Sistem"
echo "  2. Auto Login Desktop"
echo ""
echo "  === NETWORK ==="
echo "  3. Install Tailscale"
echo "  4. Ganti MAC Address LAN (LINK FILE)"
echo ""
echo "  === PACKAGE SYSTEM ==="
echo "  5. Install Snap"
echo "  6. Install Flatpak + Flathub"
echo ""
echo "  === APPLICATIONS ==="
echo "  7. Install Nginx"
echo "  8. Install Chromium"
echo "  9. Install RustDesk"
echo " 10. Install Mumble Server"
echo " 11. Install Mumble Client"
echo " 12. Install Shinobi CCTV (NVR)"
echo " 13. Install Portainer (Docker GUI)"
echo " 14. Install File Browser (Web UI)"
echo " 15. Install HestiaCP (Custom Script)"
echo ""
echo "------------------------------------"
echo " 16. Reboot STB"
echo " 17. Power Off STB"
echo "  0. Keluar"
echo "===================================="
read -p "Pilih nomor: " pilih

case $pilih in

1)
    sudo apt update && sudo apt upgrade -y
    read -p "ENTER..."
    ;;

2)
    USERNAME=$(logname)
    sudo mkdir -p /etc/lightdm/lightdm.conf.d
    echo -e "[Seat:*]\nautologin-user=$USERNAME" | sudo tee /etc/lightdm/lightdm.conf.d/50-autologin.conf
    read -p "ENTER..."
    ;;

3)
    curl -fsSL https://tailscale.com/install.sh | sh
    read -p "ENTER..."
    ;;

4)
    read -p "MAC baru (AA:BB:CC:DD:EE:FF): " NEWMAC
    sudo mkdir -p /etc/systemd/network
    sudo tee /etc/systemd/network/10-eth0.link > /dev/null <<EOF
[Match]
OriginalName=eth0

[Link]
MACAddress=$NEWMAC
EOF
    echo "MAC aktif setelah reboot."
    read -p "ENTER..."
    ;;

5)
    sudo apt install -y snapd
    sudo systemctl enable snapd
    read -p "ENTER..."
    ;;

6)
    sudo apt install -y flatpak
    flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
    read -p "ENTER..."
    ;;

7)
    sudo apt install -y nginx
    read -p "ENTER..."
    ;;

8)
    sudo apt install -y chromium
    read -p "ENTER..."
    ;;

9)
    cd /tmp
    wget https://github.com/rustdesk/rustdesk/releases/download/1.4.5/rustdesk-1.4.5-aarch64.deb -O rustdesk.deb
    sudo apt install -y ./rustdesk.deb
    rm -f rustdesk.deb
    read -p "ENTER..."
    ;;

10)
    ensure_docker
    sudo docker run -d \
      --name mumble-server \
      --restart=always \
      --network=host \
      mumblevoip/mumble-server
    read -p "ENTER..."
    ;;

11)
    flatpak install -y flathub info.mumble.Mumble
    read -p "ENTER..."
    ;;

12)
    sudo apt update
    sudo apt install -y git curl ffmpeg
    git clone https://gitlab.com/Shinobi-Systems/Shinobi.git /root/Shinobi
    cd /root/Shinobi
    sudo chmod +x INSTALL/ubuntu.sh
    sudo INSTALL/ubuntu.sh
    read -p "ENTER..."
    ;;

13)
    ensure_docker
    sudo docker volume create portainer_data
    sudo docker run -d \
      --name portainer \
      --restart=always \
      -p 9000:9000 \
      -v /var/run/docker.sock:/var/run/docker.sock \
      -v portainer_data:/data \
      portainer/portainer-ce
    read -p "ENTER..."
    ;;

14)
    ensure_docker
    sudo docker run -d \
      --name filebrowser \
      --restart=always \
      -p 8081:80 \
      -v /:/srv \
      filebrowser/filebrowser
    read -p "ENTER..."
    ;;

15)
    ensure_docker
    cd /root
    wget https://raw.githubusercontent.com/hestiacp/hestiacp/release/install/hst-install.sh
    chmod +x hst-install.sh

    bash hst-install.sh \
      --lang 'id' \
      --hostname 'vps.stafa.net.id' \
      --username 'Syafiizaa' \
      --email 'piigaulbro@gmail.com' \
      --password 'Kotori01' \
      --apache no \
      --named no \
      --exim no \
      --dovecot no \
      --clamav no \
      --spamassassin no \
      --iptables no

    read -p "ENTER..."
    ;;

16)
    sudo reboot
    ;;

17)
    sudo poweroff
    ;;

0)
    exit
    ;;
esac
done
