import sys
import os
#from instagrapi import Client


uid=sys.argv[1]
gid=sys.argv[2]
TEXT=sys.argv[3]
FILE=sys.argv[4]
NAME=sys.argv[5]

admingroup = "NiZFSzOdvI5aysoKSp6tOPOGqCqKaqWKn+/kAtAt7wY="

def sendsublist(text):
	with open("./Data/Subscribed") as sublist:
			users = [line.rstrip() for line in sublist]
			for usr in users:
				sendmessage(posttext, usr, FILE)

def postmastodon(text):
	print("Posting on Mastodon...")
	if FILE == "":
		os.system(f'toot post "{text}"')
	else:
		os.system(f'toot post "{text}" -m "{FILE}"')
	
def postinstagram(text = ""):
	''' ### this works fine, just didn't get instagrapi itself working on my serer yet
	
	client = Client()
	with open("./Data/Instagram") as loginfile:
			credentials = [line.rstrip() for line in loginfile]
			client.login(username=credentials[0], password=credentials[1])
	if FILE == "":
		client.photo_upload("./neues_event.png", caption=text)
	else:
		client.photo_upload(FILE, caption=text)
	print("posted on Instagram")
	'''
	print("*pretending like I am posting something on Instagram*")

def posthtml(text):
	HTMLdiv = f"<div class='message'>{text}</div>"
    os.system(f'echo "{HTMLdiv}" >> "/home/signalticker/public_html/messages.html"')

	

def sendmessage(message, recipient = uid, file = ""):
	if file == "":
		os.system(f'signal-cli --dbus send "{recipient}" -m "{message}"')
	else:
		os.system(f'signal-cli --dbus send "{recipient}" -m "{message}" -a "{file}"')

def sendadmins(message, attachment):
	if attachment and not FILE == "":
		os.system(f'signal-cli --dbus send -g "{admingroup}" -m "{message}" -a "{FILE}"')
	else:
		os.system(f'signal-cli --dbus send -g "{admingroup}" -m "{message}"')

def post(posttext):
	#postmastodon(posttext)
	#postinstagram(posttext)
	posthtml(posttext)
	#sendsublist(posttext)
		
def search(location, term):
	with open(location) as file:
		contents = file.read()
		if term in contents:
			return 1
		else:
			return 0

#there is a builtin way to disable the bot temporarily
with open("./Data/Enable") as file:
	global enable
	enable = file.read().strip() == "True"

#checks if the author wants to send a command
commandmode = 0
prefix = "."
if TEXT.startswith(prefix) and gid == "" and enable:
	command = TEXT.lower()
	command = command.split(" ",1)[0]
	command = command[1:]
	print(f"command is: {command}")
	commandmode = 1

#this is where we check if they have subscribed
subscribed = search("./Data/Subscribed", uid)
if subscribed:
	print("Autormensch hat Abonniert!")

#this is where we check if they are an admin
admin = search("./Data/Admins", uid)
if admin:
	print("Autormensch ist Admin!")

if TEXT.startswith(f"{prefix}enable") and admin:
	os.system(f"echo {not enable} > ./Data/Enable")
	sendmessage(f"enable Status ist auf: {not enable}")
	exit()

#this is where the commands go
if commandmode:
		
	if command == "ping":
		sendmessage("pong")
			
	if command == "help":
		sendmessage(f'''$(printf "Hier ist eine Liste von commands:
{prefix}subscribe fügt dich zu der Verteilerliste hinzu
{prefix}unsubscribe entfernt dich von der Verteilerliste
{prefix}ping ... find das am Besten selbst herraus :)
{prefix}post postet einen Aufruf auf allen Kanälen")''')
	
	if command == "helphidden":
		sendmessage(f'''$(printf "Hier ist eine Liste von geheimen commands:
{prefix}enable aktiviert/deaktiviert den Bot (admin only)")''')
				
	if command == "subscribe":
		if subscribed:
			sendmessage("du bist schon abonniert :)")
		else:
			os.system(f'echo {uid} >> ./Data/Subscribed')
			sendmessage("du wurdest der Liste hinzugefügt")
	
	if command == "unsubscribe":
		if subscribed:
			os.system(f'sed -i /{uid}/d  ./Data/Subscribed')
			sendmessage("du wurdest erfolgreich entfernt")
		else:
			sendmessage("Du Witzbolt hast garnicht auf der Liste gestanden, hihi")
			
	if command == "post":
		try:
			posttext = TEXT.split(" ",1)[1]
		except IndexError:
			posttext = ""
		
		if post == "" and FILE == "":
			sendmessage("Gib bitte eine Nachricht zum posten, oder ein Bild an") 
			
		if admin:
			sendmessage("Nachricht wird an alle Kanäle weitergeleitet")
			post(posttext)
			
		else:
			sendmessage("Deine Nachricht wird an die admins weitergeleitet, damit die das Reposten können :)")
			sendadmins(f"{NAME} möchte posten:",0)
			sendadmins(posttext,1)
		
else:
	if gid == "":
		if admin:
			sendmessage(f"Du bist Admin, aber hast keinen Befehl ausgewählt. Das Quick Repost Feature kommt bald, wurde aber noch nicht entwickelt. Hab also noch etwas Geduld :)")
		else:
			sendmessage(f"Hi, ich bin der Demoticker Bot! Wenn du dich fragst, was ich alles kann, schick mir eine Nachricht mit dem Inhalt '{prefix}help' (ohne anführungszeichen)!")
	else:
		print("message from group")
