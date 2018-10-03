#!/bin/sh
set -e

# Home Setup
REPO_HOME="https://github.com/josemotta/IoT.Home.Pi.git"
HOME="/home/pi/IoT.Home.Pi/"
DOCKER_COMPOSE="$HOME/home/Docker/docker-compose"
KEY_USER="josemotta@bampli.com"
KEY_FILE="/home/pi/.ssh/id_rsa"

# Hassbian scripts
#   samba:   file server
#   duckdns: dynamic dns
# DUCKDNS_DOMAIN="canoas.duckdns.org"
# DUCKDNS_TOKEN="8ce54352-8105-46e6-a82b-1317812fd6ca"
# DUCKDNS_SSL="y"
#hassbian-config install samba
#hassbian-config install duckdns << EOF
#canoas.duckdns.org
#8ce54352-8105-46e6-a82b-1317812fd6ca
#y
#EOF

# IoT.Home.Pi
git clone $REPO_HOME $HOME

# Docker
curl -fsSL get.docker.com -o get-docker.sh
sh get-docker.sh
# groupadd docker
usermod -aG docker pi

# Docker-compose
cp $DOCKER_COMPOSE /usr/local/bin
chown root:root /usr/local/bin/docker-compose
chmod 0755 /usr/local/bin/docker-compose

# Samba server only without client
sudo apt-get install -y samba samba-common-bin
# Enable this option to install server AND client
#sudo apt-get install -y samba samba-common-bin smbclient cifs-utils

# Senha inicial do "config"
sudo smbpasswd -a pi elefante

cat << EOF >> /etc/samba/smb.conf
[config]
    path = /home/pi/config
    available = yes
    valid users = pi
    read only = no
    browsable = yes
    public = yes
    writable = yes
EOF

# SSH
ssh-keygen -t rsa -b 4096 -C $KEY_USER -q -N "" -f $KEY_FILE
