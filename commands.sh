#!/bin/bash

uid=$1
gid=$2
TEXT=$3
FILE=$4

ACCOUNT=$(cat Account.txt)
ADMINGROUP="NiZFSzOdvI5aysoKSp6tOPOGqCqKaqWKn+/kAtAt7wY="
prefix="BOT"

ADMIN="0"
while read user; do
	#echo "vergleiche '$user' mit '$uid'"
	if [[ "$user" = "$uid" ]]; then
		echo "der Autormensch ist Admin"
		ADMIN="1"
	fi
done <<<$(cat Admins)	

if [[ $gid = "" ]]; then #if we have a private chat
	if [[ $TEXT = -subscribe* ]]; then
		subscribed="0"
		while read user; do
			if [[ "$user" = "$uid" ]]; then
				subscribed="1"
			fi
		done<<<subscribed
		
		if [[ subscribed = 1 ]]; then
			signal-cli -a $ACCOUNT send $uid -m "Du hast schon Abonniert :)"
		else
			echo "Abonniere $uid"
			echo "$uid" >> subscribed
			signal-cli -a $ACCOUNT send $uid -m "Du wurdest erfolgreich zur Liste hinzugefügt"
		fi
		
	elif [[ $TEXT = -unsubscribe* ]]; then
		sed -i /$uid/d  subscribed
		signal-cli -a $ACCOUNT send $uid -m "Du wurdest von der Liste entfernt"
	else
	
	
	
	
		if [[ $ADMIN = "1" ]]; then
		 ###ADMIN COMMANDS###
			signal-cli -a $ACCOUNT send $uid -m "Du bist krass"
			bash sending.sh "$TEXT" "$FILE"
			
		else
		 ###NORMAL COMMANDS###
			signal-cli -a $ACCOUNT send $uid -m "Du wurdest noch nicht verifiziert. Deine Nachricht wird manuell überprüft. Das kann einen Moment dauern, bitte habe etwas Geduld."
			if [[ $FILE != "" ]]; then
				signal-cli -a $ACCOUNT send -g $ADMINGROUP -m "$TEXT" -a "$FILE"
			else
				signal-cli -a $ACCOUNT send -g $ADMINGROUP -m "$TEXT"
			fi
		fi
	fi
fi
