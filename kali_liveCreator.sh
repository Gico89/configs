#!/bin/bash


# Script zum erstellen eines verschluesselten Kali-Sticks

IMAGE=$1

DEV=$2


#Skript Startet nur, wenn zwei Argumente uebergeben wurden und die Pfade existieren
if [ $# -gt 0 ] && [ $# -lt 3 ] && [ -e $1 ] && [ -e $2 ]; then 

	sudo dd if=$IMAGE of=$DEV bs=1M status=progress
	sync
	
	#Groeße des Images wird gelesen und in "bytes" geschrieben
	read bytes _ < <(du -bcm $IMAGE |tail -1); echo $bytes
	
	#Erstellen der Persistenten-Partition über die verbleibende Groeße des Sticks
	sudo parted $DEV mkpart primary $bytes 100%
	sync

	#Anlegen der Verschluesselung inkl. PW
	sudo cryptsetup --verbose --verify-passphrase luksFormat ${DEV}3
	sudo cryptsetup luksOpen ${DEV}3 my_usb
	sudo mkfs.ext3 -L persistence /dev/mapper/my_usb
	sudo e2label /dev/mapper/my_usb persistence
	sudo mkdir -p /mnt/my_usb
	sudo mount /dev/mapper/my_usb /mnt/my_usb
	
	#Flag-File zum einbinden als Persistenz	
	echo '/ union' | sudo tee --append /mnt/my_usb/persistence.conf
	

	sudo umount /dev/mapper/my_usb
	sudo cryptsetup luksClose /dev/mapper/my_usb

else
	echo "How-To: $ ./Script.sh [Path to Image] [Path to Dev]"
fi
