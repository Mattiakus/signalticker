#!bin/bash

MAIL="$1"
FILE="$2"
ACCOUNT=$(cat Account.txt)


while read user; do
	echo "sending $MAIL to $user"
	if [[ FILE = "" ]]; then
		signal-cli -a $ACCOUNT send "$user" -m "$MAIL"
	else
		signal-cli -a $ACCOUNT send "$user" -m "$MAIL" -a "$FILE"
	fi
done<<<$(cat subscribed)
