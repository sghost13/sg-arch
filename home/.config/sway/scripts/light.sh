#!/bin/sh
## SG
##
## Description :
## Gets longitude and latitude to set timezone for wlsunset. 
## wlsunset adjusts gamma for day/night modes on wayland.

# not currently using.

# $HOME/.config/sway/scripts/light.sh

# install wlsunset
CONTENT=$(curl -s https://freegeoip.app/json/)
longitude=$(echo $CONTENT | jq .longitude)
latitude=$(echo $CONTENT | jq .latitude)
wlsunset -l $latitude -L $longitude
