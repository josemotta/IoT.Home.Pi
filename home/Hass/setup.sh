#!/bin/sh
set -e

# Home Setup
HOME="/home/pi/IoT.Home.Pi/home"
DOCKER_COMPOSE="$HOME/Docker/docker-compose"
KEY_USER="josemotta@bampli.com"
KEY_FILE="/home/pi/.ssh/id_rsa"
BACKUP_FOLDER=/home/pi/backup/
DEFAULT_CONFIG=*_hassconfig_*

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

cp ${HOME}/Hass/${DEFAULT_CONFIG} ${BACKUP_FOLDER}

# Docker
curl -fsSL get.docker.com -o get-docker.sh
sh get-docker.sh
sudo usermod -aG docker pi

# Docker-compose
sudo cp $DOCKER_COMPOSE /usr/local/bin
sudo chown root:root /usr/local/bin/docker-compose
sudo chmod 0755 /usr/local/bin/docker-compose

# Senha inicial do "config"
#sudo smbpasswd -a pi elefante

# SSH
ssh-keygen -t rsa -b 4096 -C $KEY_USER -q -N "" -f $KEY_FILE
