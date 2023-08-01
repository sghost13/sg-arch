#!/usr/bin/env zsh

# Using read in zsh to prompt for user input and react based upon said input.

red() { local RED="$(tput setaf 1)" ; builtin echo -e "${RED}$1${NORMAL}"; } ;
green() { local GREEN="$(tput setaf 2)" ; builtin echo -e "${GREEN}$1${NORMAL}"; } ;
yellow() { local YELLOW="$(tput setaf 3)" ; builtin echo -e "${YELLOW}$1${NORMAL}"; } ;

read "VARIABLE?Message goes here. Continue? Y/N "
if [[ "$VARIABLE" =~ ^[Yy]$ ]] ; then
	green "Answered Yes. (Y or y)"
elif [[ "$VARIABLE" =~ ^[Nn]$ ]] ; then
	red "Answered No. (N or n)"
else
	red "Didnt answer Yy or Nn. Exiting..."
fi
