#!/bin/bash


# Bash-Script to create an encrypted Kali-Live-USB-Stick

IMAGE=$1

DEV=$2


# Conditions to execute the script, are valid arguments
if [ $# -gt 0 ] && [ $# -lt 3 ] && [ -e $1 ] && [ -e $2 ]; then 

	sudo dd if=$IMAGE of=$DEV bs=1M status=progress
	sync
	
	#Size of the image are stored in "bytes"
	read bytes _ < <(du -bcm $IMAGE |tail -1); echo $bytes
	
	#Creates the persistance over the entire size of the USB-Stick
	sudo parted $DEV mkpart primary $bytes 100%
	sync

	#Creates the encrypted patition
	sudo cryptsetup --verbose --verify-passphrase luksFormat ${DEV}3
	sudo cryptsetup luksOpen ${DEV}3 my_usb
	sudo mkfs.ext3 -L persistence /dev/mapper/my_usb
	sudo e2label /dev/mapper/my_usb persistence
	sudo mkdir -p /mnt/my_usb
	sudo mount /dev/mapper/my_usb /mnt/my_usb
	
	#Flag-File for the persistance	
	echo '/ union' | sudo tee --append /mnt/my_usb/persistence.conf
	

	sudo umount /dev/mapper/my_usb
	sudo cryptsetup luksClose /dev/mapper/my_usb

else
	echo "How-To: $ ./Script.sh [Path to Image] [Path to Dev]"
fi
