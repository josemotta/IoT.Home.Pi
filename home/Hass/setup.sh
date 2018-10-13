#!/bin/sh
set -e

# Home Setup
HOME="/home/pi/IoT.Home.Pi/home"
DOCKER_COMPOSE="$HOME/Docker/docker-compose"
KEY_USER="josemotta@bampli.com"
KEY_FILE="/home/pi/.ssh/id_rsa"
CONFIG_FOLDER=/home/pi/config/
BACKUP_FOLDER=/home/pi/backup/
DEFAULT_CONFIG=*_hassconfig_*
USERNAME=pi
PASSWORD=elefante

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

chmod 0777 $BACKUP_FOLDER
chmod 0777 $CONFIG_FOLDER
cp ${HOME}/Hass/${DEFAULT_CONFIG} ${BACKUP_FOLDER}

# Docker
curl -fsSL get.docker.com -o get-docker.sh
sh get-docker.sh
usermod -aG docker pi

# Docker-compose
cp $DOCKER_COMPOSE /usr/local/bin
chown root:root /usr/local/bin/docker-compose
chmod 0755 /usr/local/bin/docker-compose

# Senha inicial do "config"
echo -e "$PASSWORD\n$PASSWORD" | smbpasswd -a -s -c /etc/samba/smb.conf $USERNAME

# SSH
ssh-keygen -t rsa -b 4096 -C $KEY_USER -q -N "" -f $KEY_FILE
