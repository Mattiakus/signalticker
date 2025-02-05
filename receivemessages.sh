#!/bin/bash

ACCOUNT=$(cat Account.txt)
printf "trying to receive Messages\n"
MESSAGE=$(signal-cli -a $ACCOUNT receive --ignore-stories) 
#MESSAGE=$(cat backup.txt)
#printf "$MESSAGE"
printf "$MESSAGE" >> 'message.tmp'
printf "Received all messages\n"

if [[ $MESSAGE == '' ]]; then
	printf "No message sent\n"
else
	MESSAGE="${MESSAGE} \nEnvelope \n"
	#printf "$MESSAGE"
	printf "$MESSAGE" | while read line; do
		#printf "processing: "
		#printf "$line \n"
		
		if [[ "$line" = Envelope* ]]; then
			echo "///MESSAGE///" 	
			echo "Name:$NAME"		
			echo "Time:$(date)"		
			echo "User:$uid"		
			echo "Group:$gid"		
			echo "Text:$TEXT"		
			echo "File:$FILE"		
			echo "///MESSAGE///" 	> log.txt
			echo "Name:$NAME"		> log.txt
			echo "Time:$(date)"		> log.txt
			echo "User:$uid"		> log.txt
			echo "Group:$gid"		> log.txt
			echo "Text:$TEXT"		> log.txt
			echo "File:$FILE"		> log.txt
			
			if [[ "$TEXT" != "" ]] || [[ "$FILE" != "" ]]; then
				bash commands.sh "$uid" "$gid" "$TEXT" "$FILE"
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
		
	done
	rm ./message.tmp
fi




