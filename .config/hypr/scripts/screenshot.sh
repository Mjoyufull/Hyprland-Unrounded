#!/usr/bin/bash 
hyprpicker -rz &
sleep 0.1
grim -g "$(slurp -d)" - | wl-copy && pkill hyprpicker

NAME=/home/chris/Pictures/Screenshots/Screenshot_$(date -u +%Y%m%d-%H%M%S).png

if [ "$(wl-paste | wc -c)" -gt 1 ]; then
    wl-paste > $NAME
fi

wl-paste | swappy -f - -o $NAME

notify-send -e "Screenshot taken" -i /usr/share/icons/Papirus-Dark/22x22/devices/camera-photo.svg & play ~/.config/hypr/assets/sounds/camera-shutter.ogg
