#!/bin/bash
# jmrl adapted from usb_backup.sh to save yaml configuration with 3 operations:
#   1. backup hostname.hass.config.yaml.zip (this script)
#   2. push it to Github and
#   3. pull latest in order to reset Homeassistant with a fresh DB.

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
        echo ${LATEST_FILE}
        popd >/dev/null

        log i "Reset complete: ${LATEST_FILE}"
else
        log e "Backup folder not found, is your USB drive mounted?" 1
fi
