#!/bin/sh

cd $(dirname "$0")

# FUNCTION TO VALIDATE A VARIABLE IS NOT EMPTY
function validate_variable() {
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
oldip=$(cat /data/ip.txt 2> /dev/nul)
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
if [[ ! -z "$mail_to" ]]; then
	mail_file="/tmp/mail.txt"
	echo -e "Dynu IP changed to $ip for ${dynu_location}\n$result" >"${mail_file}"
	curl \
		--silent \
		--url "smtps://smtp.gmail.com:465" \
		--user "${mail_user}" \
		--mail-from "${mail_from}" \
		--mail-rcpt "${mail_to}" \
		--upload-file "${mail_file}"
fi
