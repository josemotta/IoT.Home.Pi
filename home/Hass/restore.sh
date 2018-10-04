#!/bin/bash
# jmrl - Adapted from usb_backup.sh to save Homeassistant yaml configuration:
#   1. backup yaml files to zip based on hostname (see backup.sh)
#   2. push it to Github and/or pull it back again
#   3. restore latest backup (this script)
# These actions should reset Homeassistant to a fresh DB.

BACKUP_FOLDER=/home/pi/backup/
LATEST_FILE=$(find ${BACKUP_FOLDER} -maxdepth 1 -name '*_hassconfig_*' | sort -t_ -nk3,4 | tail -n1)
BACKUP_LOCATION=/home/pi/config

log() {
        if [ "${DEBUG}" == "true" ] || [ "${1}" != "d" ]; then
                echo "[${1}] ${2}"
                if [ "${3}" != "" ]; then
                        exit ${3}
                fi
        fi
}

if [ -d "${BACKUP_FOLDER}" ]; then
        if [ ! -e "${LATEST_FILE}" ]; then
                log e "No backup file found, is it correct?" 1
                exit
        fi
        pushd ${BACKUP_LOCATION} >/dev/null
        rm -r  ${BACKUP_LOCATION}
        mkdir -m 0777 ${BACKUP_LOCATION}
        unzip -o ${LATEST_FILE} -d ${BACKUP_LOCATION}
        chmod 0666 ${BACKUP_LOCATION}/*.yaml
        popd >/dev/null

        log i "Reset complete: ${LATEST_FILE}"
else
        log e "Backup folder not found, is your USB drive mounted?" 1
fi
