#!/usr/bin/env bash

# ----------------- COLOR ----------------- COLOR ----------------- COLOR ----------------- COLOR -----------------

### Colors ##
ESC=$(echo '\033') RESET="${ESC}[0m" BLACK="${ESC}[30m"
RED="${ESC}[31m" GREEN="${ESC}[32m" YELLOW="${ESC}[33m" BLUE="${ESC}[34m"
MAGENTA="${ESC}[35m" CYAN="${ESC}[36m" WHITE="${ESC}[37m" DEFAULT="${ESC}[39m"

### Color Functions ##
black() { echo -e "${BLACK}$1${RESET}"; } ;
red() { echo -e "${RED}$1${RESET}"; } ;
green() { echo -e "${GREEN}$1${RESET}"; } ;
yellow() { echo -e "${YELLOW}$1${RESET}"; } ;
blue() { echo -e "${BLUE}$1${RESET}"; } ;
magenta() { echo -e "${MAGENTA}$1${RESET}"; } ;
cyan() { echo -e "${CYAN}$1${RESET}"; } ;
white() { echo -e "${WHITE}$1${RESET}"; } ;
default() { echo -e "${DEFAULT}$1${RESET}"; } ;

# ----------------- USER ----------------- USER ----------------- USER ----------------- USER -----------------

# Ensure propper home directory ownership/permissions.
dir-home() { chmod --changes --preserve-root 700 "$1" ; chown --verbose --preserve-root "$USER:$USER" "$1" ; }
# Ensure propper home file ownership/permissions.
file-home() { chmod --changes --preserve-root 600 "$1" ; chown --changes --preserve-root "$USER:$USER" "$1" ; }

# Test for file or dir, then use previous file_home & dir_home functions depending, to ensure proper ownership/permissions.
file-or-dir() { if [[ -d "$1" ]] ; then dir-home "$1" ; fi ; if [[ -f "$1" ]]; then file-home "$1" ; fi ; }

mkdir-if-missing() {
# If needed home directory is missing, make it, use previous to test, and ensure propper ownership/permissions.
    if [[ ! -d "$1" ]] ; then mkdir "$1" ; green "Creating directory "$1" " ; file-or-dir "$1" ; fi ;
# If needed home directory exhists, remove it, then do the above.
#    if [[ -d "$1" ]] ; then rm -rf "$1" ; mkdir "$1" ; red "Creating directory "$1" " ; file-or-dir "$1" ; fi ;
# If DIR exhists, say so.
    if [[ -d "$1" ]] ; then yellow "Directory "$1" exhists" ; fi ;
}

mkfile-if-missing() {
# If needed home file is missing, make it, use previous to test, and ensure propper ownership/permissions.
    if [[ ! -f "$1" ]] ; then touch "$1" ; green "Creating file "$1" " ; file-or-dir "$1" ; fi ;
# If needed home file exhists, remove it, then do the above.
#    if [[ -f "$1" ]] ; then rm -rf "$1" ; touch "$1" ; red "Creating file "$1" " ; file-or-dir "$1" ; fi ;
# If file exhists, say so.
    if [[ -f "$1" ]] ; then yellow "File "$1" exhists" ; fi ;
}


if [[ "$EUID" -ne 0 ]] ; then
	green "User is $USER, all good."
	mkdir-if-missing /dir
	mkfile-if-missing /file
else
	red "User is ROOT, not making missing dirs/files."
	exit 1
fi

# ----------------- ROOT ----------------- ROOT ----------------- ROOT ----------------- ROOT -----------------

# Ensure propper home directory ownership/permissions.
dir-root() { chmod --changes --preserve-root 700 "$1" ; chown --verbose --preserve-root "$USER:$USER" "$1" ; }
# Ensure propper home file ownership/permissions.
file-root() { chmod --changes --preserve-root 600 "$1" ; chown --changes --preserve-root "$USER:$USER" "$1" ; }

# Test for file or dir, then use previous file_home & dir_home functions depending, to ensure proper ownership/permissions.
file-or-dir() { if [[ -d "$1" ]] ; then dir-root "$1" ; fi ; if [[ -f "$1" ]]; then file-root "$1" ; fi ; }

# If needed home directory is missing, make it, use previous to test, and ensure propper ownership/permissions.
mkdir-if-missing() { if [[ ! -d "$1" ]] ; then mkdir "$1" ; echo "Creating directory "$1" " ; file-or-dir "$1" ; fi }
# If needed home file is missing, make it, use previous to test, and ensure propper ownership/permissions.
mkfile-if-missing() { if [[ ! -f "$1" ]] ; then touch "$1" ; echo "Creating file "$1" " ; file-or-dir "$1" ; fi }

if [[ "$EUID" -ne 0 ]] ; then
	red "User is not ROOT, not making missing dirs/files."
	exit 1
else
	green "User is ROOT, all good."
	mkdir-if-missing /dir
	mkfile-if-missing /file
fi

# ----------------- ASK-USER ----------------- ASK-USER ----------------- ASK-USER ----------------- ASK-USER -----------------
