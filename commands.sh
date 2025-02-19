#!/bin/bash

uid="$1"
gid="$2"
TEXT="$3"
FILE="$4"
NAME="$5"

ACCOUNT=$(cat ./Data/Account)
ADMINGROUP="NiZFSzOdvI5aysoKSp6tOPOGqCqKaqWKn+/kAtAt7wY="
prefix="BOT"

ADMIN="0"
while read user; do
	#echo "vergleiche '$user' mit '$uid'"
	if [[ "$user" = "$uid" ]]; then
		echo "der Autormensch ist Admin"
		ADMIN="1"
	fi
done <<<$(cat ./Data/Admins)

SUBBED="0"
while read user; do	
	if [[ "$user" = "$uid" ]]; then
		echo "der Autormensch hat abonniert"
		SUBBED="1"
	fi
done <<<$(cat ./Data/Subscribed)

if [[ $gid = "" ]]; then
	GROUP="0"
else
	GROUP="1"
fi

if [[ "$TEXT" = -shouts* ]]; then

	signal-cli --dbus -a "$ACCOUNT" send "$uid" -m "$(cat ./Data/Shouts/${TEXT#-shouts })"

elif [[ "$TEXT" = -help* ]]; then

	signal-cli --dbus -a "$ACCOUNT" send "$uid" -m "$(printf "Hier ist eine Liste von commands:\n-shouts [Antifa|Umwelt] zeigt eine Liste mit Demorufen an\n-subscribe fügt dich zu der Verteilerliste hinzu\n-unsubscribe entfernt dich von der Verteilerliste")" &

elif [[ $TEXT = -subscribe* ]] && [[ $GROUP = "0" ]]; then

	if [[ $SUBBED = "1" ]]; then
		signal-cli --dbus -a $ACCOUNT send $uid -m "Du hast schon Abonniert :)" &
	else
		echo "Abonniere $uid"
		echo "$uid" >> ./Data/Subscribed
		signal-cli --dbus -a $ACCOUNT send $uid -m "Du wurdest erfolgreich zur Liste hinzugefügt" &
	fi

elif [[ $TEXT = -unsubscribe* ]] && [[ $GROUP = "0" ]]; then

	sed -i /$uid/d  ./Data/Subscribed
	signal-cli --dbus -a $ACCOUNT send $uid -m "Du wurdest von der Liste entfernt" &

elif [[ $GROUP = "0" ]]; then
	if [[ $ADMIN = "1" ]]; then
	 ###ADMIN COMMANDS###
		signal-cli --dbus -a $ACCOUNT send $uid -m "Du bist krass" &
		bash ./Bash/sending.sh "$TEXT" "$FILE" "$NAME" &
		
	else
	 ###NORMAL COMMANDS###
		signal-cli --dbus -a $ACCOUNT send $uid -m "Du wurdest noch nicht verifiziert. Deine Nachricht wird manuell überprüft. Das kann einen Moment dauern, bitte habe etwas Geduld." &
		if [[ $FILE != "" ]]; then
			signal-cli --dbus -a $ACCOUNT send -g $ADMINGROUP -m "$NAME:" &
			signal-cli --dbus -a $ACCOUNT send -g $ADMINGROUP -m "$TEXT" -a "$FILE" &
		else
			signal-cli --dbus -a $ACCOUNT send -g $ADMINGROUP -m "$NAME:" &
			signal-cli --dbus -a $ACCOUNT send -g $ADMINGROUP -m "$TEXT" &
		fi
	fi
fi
