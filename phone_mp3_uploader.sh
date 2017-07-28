#!/bin/bash
#mp3 uploader to usb mp3player. Script must be placed in music directory. And will copy
#albums/folders recursively to mp3 player. Will only list folders in menu,
#not individual songs. Try to orginize your music into folders. And folder should not
#contain blank spaces.
#Author: Jorge L. Vazquez
#Date: 03/24/2014
 
player=""		#directory which mp3player is mounted
device="sdb"		#/device of mp3player usually /dev/sdb
playerSize=""		#mp3player size in megabytes
freeSpace=""		#mp3player free space
songsize=""		#size of song folder to be copied to mp3player
artist=""		#name of artist to be copied
 
#getting mp3 player free space
get_freeSpace() {
	freeSpace=$(df | grep $device | awk '{print $4}')
}
 
#detect mp3 player 
detect_mp3payer() {
	player=$(df | grep $device | awk '{print $6}' 2>/dev/null)
	if [ ! -d $player ]; then
		echo "$PLAYER is not a directory"
		exit -1
	fi
 
	playerSize=$(df | grep $device | awk '{print $2}')
	get_freeSpace
	echo "mp3player: $player"
	echo "size: $((playerSize/1024))M"
	echo "free: $((freeSpace/1024))M"
}
 
#calculate size of songs to be loaded to mp3 player
get_song() {
	artist=$(ls -d */ | head -"$1" | tail -1 | sed 's/\///g')
	songSize=$(du --max-depth=1 . | grep "$artist" | awk '{print $1}')
}
 
 
#####################################
#	MAIN
#####################################
 
detect_mp3payer
 
#display menu of of list of artist
echo "========= SONG LIST =========="
ls -d */ | cat -n | sed 's/\///g' 2>/dev/null
if [ $? -ne 0 ]; then echo "Error, Exiting program..", exit 1; fi
 
#select artist 
echo -n "Enter artist index in sequence eg: 1 3 10..N :"
read sequence
echo 
 
#looping through every artist and copying to player
for num in ${sequence}; do
	#getting artist folder size and name
	get_song $num
	get_freeSpace
	#copying songs to mp3player
	if (( songSize < freeSpace )); then
		echo "copying $artist to mp3player..."
		cp -rf "$artist" $player
	else
		echo "not enough space in mp3player for "$artist", exiting..."
		exit 1
	fi
 
	echo -e "finished!... $((freeSpace/1024))M free space in mp3 player \n"	
done
 
echo "DONE COPYING SONGS!...."
