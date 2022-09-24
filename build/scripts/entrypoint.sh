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
	# MAKE SURE WE HAVE ACCESS TO THE DATA DIRECTORY
	if [ ! -w /data ]; then
		echo "ERROR: No write access to 'data' directory"
		echo "Note: 'chown -R $(id -u) data'"
		exit 1
	fi

	# MAKE SURE WE HAVE ACCESS TO MAIL LOGS
	touch ${MSMTP_LOG_FILE} >/dev/null 2>&1 || true
	if [ ! -w ${MSMTP_LOG_FILE} ]; then
		echo "ERROR: No write access to $(basename ${MSMTP_LOG_FILE})"
		echo "Note: 'chown -R $(id -u) $(basename ${MSMTP_LOG_FILE})'"
		exit 1
	fi

	# MAKE SURE WE HAVE ACCESS TO DYNU LOGS
	touch ${DYNU_LOG_FILE} >/dev/null 2>&1 || true
	if [ ! -w ${DYNU_LOG_FILE} ]; then
		echo "ERROR: No write access to $(basename ${DYNU_LOG_FILE})"
		echo "Note: 'chown -R $(id -u) $(basename ${DYNU_LOG_FILE})'"
		exit 1
	fi
	tail -f -n0 "${DYNU_LOG_FILE}" &

	touch /tmp/crond.log
	tail -f /tmp/crond.log &

	supercronic ~/crontab >/tmp/crond.log 2>&1
	exit 1
fi

exec "$@"
