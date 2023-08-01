

#Quick copy colors
RESET="\033[0m"
RED="\033[31m"
YELLOW="\033[33m"
GREEN="\033[32m"
BLUE="\033[34m"

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

black poopy
red poopy
green poopy
yellow poopy
blue poopy
magenta poopy
cyan poopy
white poopy
default poopy
#-----------------------------------------------------------------------------
# Append this, with that.

# Add options to the end of a variable listed elsewhere.
# Just make THIS="VAR_I_WANT_TO_ADD_TOO", and THAT=" options i want to add"
# $THAT needs a space at beginning, and spaces between the options.

THIS=""
THAT=" "
append_this () {
    case "${THIS}" in
        *"$1")
            ;;
        *)
            THIS="${THIS+${THIS}}${1}"
    esac
}
append_this "${THAT}"
#-----------------------------------------------------------------------------
# create copy of file named file.bak  usage: bak <file>
bak() {
cp "$1"-$(date +"%Y-%m-%d"){,.bak};
}

#-----------------------------------------------------------------------------
# check if a command exhists
command_exists () {
    command -v $1 >/dev/null 2>&1;
}
#-----------------------------------------------------------------------------
# same as above, but uses hash
is-installed() { hash "$1" 2>/dev/null && blue "$1 is installed." || echo >&2 "You need to install "$1". Aborting." }

is-installed pacman

is-installed poop

#-----------------------------------------------------------------------------
# Show allocated disk space:

allocated-disk{

allocated="$(df -klP -t xfs -t ext2 -t ext3 -t ext4 -t reiserfs | grep -oE ' [0-9]{1,}( +[0-9]{1,})+' | awk '{sum_used += $1} END {printf "%.0f GB\n", sum_used/1024/1024}')"
echo "$allocated"
}


# Show used disk space

used-disk{

used="$(df -klP -t xfs -t ext2 -t ext3 -t ext4 -t reiserfs | grep -oE ' [0-9]{1,}( +[0-9]{1,})+' | awk '{sum_used += $2} END {printf "%.0f GB\n", sum_used/1024/1024}')"
echo "$used"
}
#-----------------------------------------------------------------------------
whitespace() {
sed -i 's/^[ \t]*//' "$1";
}
#-----------------------------------------------------------------------------
# Prompt user with yes or no and react accordingly.

read -r -p "Throw poop? <y/n> " prompt
if [[ $prompt == "y" || $prompt == "Y" || $prompt == "yes" || $prompt == "Yes" ]] ; then
echo "Poop thrown."
else
echo "Holding it in."
fi
#-----------------------------------------------------------------------------
# Some good substituion to use.

dir="/path/to/dir/filename.type.type2"

#this prints only the filename.type.type2
# for f in $(find "$dir" -type f -printf "%f\n") ; do


for f in $dir ; do
# exclude symlinks
	[ -L "${f%/}" ] && continue

# THIS:
# Substitution. removes up to and including last / in dir name.
# Output: filename.type.type2
red "${f##*/}"

# Same but only furthest left / removed. 
# Output: path/to/dir/filename.type.type2
green "${f#*/}"


# %% denotes the end of name. this removes entire end of filename.
# Output: /path/to/dir/filename
magenta "${f%%.*}"

# single percent
# Output: /path/to/dir/filename.type
blue "${f%.*}"

done
#-----------------------------------------------------------------------------
# run scripts in directory

run_scripts () {
    for script in $1/*; do

        #  skip non-executable snippets
        [ -x "$script" ] || continue

        # execute $scripts in the contect of the current shell
        . $script

    done

}

run_scripts path/to/hooks.d
#-----------------------------------------------------------------------------
# run as root

# This will run as non-root user.(unless logged in as root)
echo "$USER"

# This will run as root.
sudo bash -c 'echo "$USER"'

# This will run as non-root user.(unless logged in as root)
echo "$USER"
#-----------------------------------------------------------------------------
# Echo all files in "$dir", containing glob "$name".


dir="/lib/modules/$(uname -r)/kernel/drivers/net/wireless"
name="*.ko.zst"

for f in $(find -maxdepth 2 "$dir" -name "$name" -type f) ; do
echo "$f"
done
#-----------------------------------------------------------------------------
#takes all files in dir(not . files), adds the full path filenames to $(file).use:  usage: sls <save.file>
sls() {
find $(pwd) -maxdepth 1 -type f -not -path '*/\.*' | sed 's/^\.\///g' | sort >>"$1";
}
#-----------------------------------------------------------------------------
# Is user root?
if [[ "$EUID" -ne 0 ]] ; then
echo "User is not ROOT"
else
echo "User is ROOT" 
fi
#-----------------------------------------------------------------------------
