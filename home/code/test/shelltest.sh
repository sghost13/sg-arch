#!/usr/bin/env bash

red() { local RED="$(tput setaf 1)" ; builtin echo -e "${RED}$1${NORMAL}"; } ;
green() { local GREEN="$(tput setaf 2)" ; builtin echo -e "${GREEN}$1${NORMAL}"; } ;
yellow() { local YELLOW="$(tput setaf 3)" ; builtin echo -e "${YELLOW}$1${NORMAL}"; } ;


# Gets the script name like : ./scriptname
# If just in shell get the current shell like : bash or zsh
echo "$0"

# Gets the script name like : scriptname
# If just in shell gets the current shell like : bash or zsh
"$(basename "$0")"

# echo "$(which zsh)"
# echo "$(which bash)"

# change shells
# chsh "$(which bash)"
# chsh "$(which zsh)"

if [[ "$(basename "$SHELL")" =~ "bash" ]] ; then
	green "$SHELL"
	green "Using bash"
elif [[ "$(basename "$SHELL")" =~ "zsh" ]] ; then
	green "$SHELL"
	green "Using zsh"
fi
