#!/bin/bash

# Get the PID of the main slideshow script
slideshowPid=$(cat /tmp/wallpaper_slideshow_pid)

# Send the signal to go to the next wallpaper
kill -USR1 "$slideshowPid"

# Kill this trigger script after it runs
kill $$

