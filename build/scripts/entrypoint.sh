#!/bin/sh

set -e

# CONVERT 1PASSWORD ENVIRONMENT VARIABLES
if env | grep -E '^[^=]*=OP:' >/dev/null; then
	curl -sS -o /tmp/1password-vars.sh "https://raw.githubusercontent.com/JtMotoX/1password-docker/main/1password/op-vars.sh"
	chmod 755 /tmp/1password-vars.sh
	. /tmp/1password-vars.sh || exit 1
	rm -f /tmp/1password-vars.sh
fi

if [ "$1" = "run" ]; then
	# MAKE SURE WE HAVE ACCESS TO MAIL LOGS
	touch ${MSMTP_LOG_FILE} >/dev/null 2>&1 || true
	[ -w ${MSMTP_LOG_FILE} ] || { "No write access to ${MSMTP_LOG_FILE}"; exit 1; }

	mkdir -p /var/log/dynu-updater
	touch /var/log/dynu-updater/dynu-updater.log
	tail -f -n0 /var/log/dynu-updater/dynu-updater.log &

	touch /tmp/crond.log
	tail -f /tmp/crond.log &

	crond -f -l 8 -L /tmp/crond.log
	exit
fi

exec "$@"
