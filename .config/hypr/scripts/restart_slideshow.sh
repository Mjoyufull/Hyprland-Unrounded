#!/bin/bash

# Path to the original slideshow script
SLIDESHOW_SCRIPT="/home/chris/.config/hypr/scripts/slideshow.sh"

# Check if the slideshow script is currently running
if pgrep -f "$SLIDESHOW_SCRIPT" > /dev/null; then
    echo "Killing existing slideshow process..."
    pkill -f "$SLIDESHOW_SCRIPT"
fi

echo "Starting slideshow..."
$SLIDESHOW_SCRIPT

