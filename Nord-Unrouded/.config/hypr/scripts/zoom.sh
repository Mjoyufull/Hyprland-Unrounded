#!/usr/bin/bash
export currZoom="$(hyprctl getoption cursor:zoom_factor | grep float | sed s/float\:\ //)" 

case $1 in 
in )
hyprctl keyword cursor:zoom_factor $(echo "$currZoom +0.25" | bc)
dunstify -t 1500 -h string:x-dunst-stack-tag:zoom "Zoom is at: $(hyprctl getoption cursor:zoom_factor | grep float | sed s/float:\ //|sed s/0000//)x"
;;

out )
  if (( $(echo "$currZoom > 1.0" |bc -l) )); 
  then hyprctl keyword cursor:zoom_factor $(echo "$currZoom -0.25" | bc)
  dunstify -t 1500 -h string:x-dunst-stack-tag:zoom "Zoom is at: $(hyprctl getoption cursor:zoom_factor | grep float | sed s/float:\ //|sed s/0000//)x"
  fi
;;
zero )
hyprctl keyword cursor:zoom_factor 1
dunstify -t 1500 -h string:x-dunst-stack-tag:zoom "Zoom Reset"
;;
* )
  echo "L+ratio+skill issue"
  exit 1;;
esac