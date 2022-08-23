#!/bin/sh

cd $(dirname "$0")

# FUNCTION TO VALIDATE A VARIABLE IS NOT EMPTY
validate_variable() {
	variable_key="$1"
	variable_value=$(eval "echo \$${variable_key}")
	if [ -z "${variable_value}" ]; then
		echo "You need to provide the '${variable_key}' in .env file"
		exit 1
	fi
}

# VALIDATE THAT WE HAVE ALL REQUIRED VARIABLES
validate_variable dynu_username
validate_variable dynu_password
validate_variable dynu_location
if [ ! -z "${mail_to}" ]; then
	validate_variable mail_from
	validate_variable mail_user
fi

# GET MY IP
url="https://api.dynu.com/ipcheck.asp"
result="`wget -qO - $url`"
ip=${result:2}
if [[ $ip =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
	echo "Your IP is $ip"
else
	echo "Error retrieving IP from $result"
	exit 1
fi

# CHECK IF IP CHANGED
oldip=$(cat /data/ip.txt 2> /dev/null)
if [[ "$ip" = "$oldip" ]]; then
	echo "IP same"
	exit 0
fi

# UPDATE IP
url="https://api.dynu.com/nic/update?username=${dynu_username}&password=${dynu_password}&location=${dynu_location}&myip=$ip&uin=1"
result="`wget -qO - $url`"

# CHECK IF DYNU UPDATED THE IP
if [[ "$result" = "nochg" ]]; then
	echo "Nothing to change"
	exit 0
fi

# IP HAS BEEN CHANGED
echo $ip >/data/ip.txt
echo "Dynu IP changed to $ip for ${dynu_location}"
echo $result

# SEND EMAIL NOTIFICATION
if [[ ! -z "${MAIL_TO_EMAIL}" ]]; then
	printf '%s\n' \
		"Subject: Dynamic IP Updated" \
		"From: Dynu Updater - ${HOST_HOSTNAME} <${MAIL_FROM_EMAIL}>" \
		"To: ${MAIL_TO_NAME} <${MAIL_TO_EMAIL}>" \
		"" \
		"Dynu IP changed to $ip for ${dynu_location}" \
		"$result" | \
		msmtp --user="${MAIL_FROM_EMAIL}" --passwordeval="echo ${MAIL_FROM_PASS}" --host=${MAIL_HOST} --port=${MAIL_PORT} -t --read-envelope-from --auth=on --tls=on --tls-starttls=on --logfile="${MSMTP_LOG_FILE}"
fi
