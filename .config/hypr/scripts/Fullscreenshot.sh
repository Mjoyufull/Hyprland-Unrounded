#!/usr/bin/bash

# Define the output path and filename with timestamp
NAME=/home/chris/Pictures/Screenshots/Screenshot_$(date -u +%Y%m%d-%H%M%S).png

# Take screenshot of all monitors and save it
grim "$NAME"

# Copy to clipboard
wl-copy < "$NAME"

# Open in swappy for editing if desired
swappy -f "$NAME" -o "$NAME"

# Play camera sound and show notification
notify-send -e "Screenshot taken" -i /usr/share/icons/Papirus-Dark/22x22/devices/camera-photo.svg & \
play ~/.config/hypr/assets/sounds/camera-shutter.ogg