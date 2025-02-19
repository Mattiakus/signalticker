#!/bin/bash

ACCOUNT=$(cat ./Data/Account)
LOGFILE="./Data/log.txt"
PASSTHROUGH="bash ./Bash/commands.sh"

	
signal-cli daemon --dbus | while read line; do
	#printf "processing: "
	#printf "$line \n"
	if [[ "$line" = "Group info:" ]] || [[ "$line" = "With profile key" ]]; then
		state="0"
	fi
	if [[ "$state" = GETTEXT ]]; then
		TEXT="$TEXT\n$line"
	else
		if [[ "$line" = Envelope* ]]; then
			if [[ "$TEXT" != "" ]] || [[ "$FILE" != "" ]]; then
				echo "///MESSAGE///" 	
				echo "Name:$NAME"		
				echo "Time:$(date)"	
				echo "Timestamp:$TIME"	
				echo "User:$uid"		
				echo "Group:$gid"		
				echo "Text:$TEXT"		
				echo "File:$FILE"		
				echo "///MESSAGE///" 	>> "$LOGFILE"
				echo "Name:$NAME"		>> "$LOGFILE"
				echo "Time:$(date)"		>> "$LOGFILE"
				echo "Timestamp:$TIME"	>> "$LOGFILE"
				echo "User:$uid"		>> "$LOGFILE"
				echo "Group:$gid"		>> "$LOGFILE"
				echo "Text:$TEXT"		>> "$LOGFILE"
				echo "File:$FILE"		>> "$LOGFILE"


				$PASSTHROUGH "$uid" "$gid" "$TEXT" "$FILE" "$NAME"
			fi
			
			NAME=""
			uid=""
			gid=""
			TIME=""
			TEXT=""
			FILE=""
			state="0" #0 for regular message, 1 for group and 2 for attachment
		
			
			uid="${line##*” }"
			uid="${uid% (device*}"
			NAME="${line#*“}"
			NAME="${NAME%”*}"
		fi
		
		if [[ "$line" = "Group info:" ]] then
			state="1"
			#echo "we have a group"
		fi
		
		if [[ "$line" = "Attachments:" ]]; then
			state="2"
			#echo "we have an attachment"
		fi
		
		if [[ $state = "0" ]]; then
			#echo "reading from regular message"
			if [[ "$line" = Body* ]]; then
				TEXT="${line:6}"
				state="GETTEXT"
			fi
			if [[ "$line" = Timestamp:* ]]; then
				TIME="${line#Timestamp: }"
				TIME="${TIME% (20*}"
			fi
			
		fi
		
		if [[ $state = "1" ]]; then
			#echo "reading group info"
			if [[ "$line" = Id* ]]; then
				gid="${line#Id: }"
			fi
		fi
		
		if [[ $state = "2" ]]; then
			#echo "reading attachment info"
			if [[ "$line" = Stored* ]]; then
				FILE="${line:21}"
			fi
		fi
	fi
done

bash ./Bash/cleanup.sh


