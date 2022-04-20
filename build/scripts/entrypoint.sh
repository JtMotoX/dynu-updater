#!/bin/sh

# MAKE SURE WE HAVE ACCESS TO MAIL LOGS
touch ${MSMTP_LOG_FILE} >/dev/null 2>&1 || true
[ -w ${MSMTP_LOG_FILE} ] || { "No write access to ${MSMTP_LOG_FILE}"; exit 1; }

mkdir -p /var/log/dynu-updater
touch /var/log/dynu-updater/dynu-updater.log
tail -f -n0 /var/log/dynu-updater/dynu-updater.log &

touch /tmp/crond.log
tail -f /tmp/crond.log &

crond -f -l 8 -L /tmp/crond.log
