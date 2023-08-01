#!/usr/bin/env bash

# Arch does not contain a /etc/default/grub.d dropin folder as debian does.
# This script adds some functions to the end of /etc/default/grub file to enable this,
#   as well as creating the new /etc/default/grub.d folder itself.
# It does not add any files to /etc/default/grub.d/**


# ----------------- functions

amiroot() {
if [[ ! $(echo "$USER") == "root" ]] ; then
    echo "Must be run as root. Exiting..."
    exit 1
else
    echo "Setting up grub as root."
fi
}

makedir() {
if [[ -d "$1" ]] ; then
    /usr/bin/chmod 770 "$1"
else
    /usr/bin/mkdir "$1" && chmod 770 "$1"
fi
}


addgrub='

#### DO NOT EDIT BELOW THIS LINE
# ----------------- setup grub.d dropin folder

# Test file exhists, can be read, owned by root, then source it.
sauce() {
if [[ -f "$1" ]] ; then
	if [[ -r "$1" ]] ; then
        if [[ $(stat -c '%U' "$1") == "root" ]] ; then
		    builtin source "$1"
        fi
	fi
fi
}

# Test dir exhists and is owned by root, then run sauce on each file within.
sauced() {
if [[ -d "$1" ]] ; then
    if [[ $(stat -c '%U' "$1") == "root" ]] ; then
    	for file in "$1"/* ; do
	    	sauce "$file"
    	done
    fi
    unset file
fi
}

sauced "/etc/default/grub.d"

'

# ----------------- script

amiroot
makedir "/etc/default/grub.d"
echo "$addgrub" >> "/etc/default/grub"
unset addgrub