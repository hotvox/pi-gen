#!/usr/bin/env bash

# never blank the screen
xset s off -dpms

# rotate to portrait mounted TV
# xrandr --output HDMI-1 --rotate left

# show a splash before browser kicks in
feh --bg-scale splash.png

# start hotvox
hotvox-device