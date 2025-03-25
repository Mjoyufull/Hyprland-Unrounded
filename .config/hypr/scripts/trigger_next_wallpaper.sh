#!/bin/bash
pidFile="/tmp/mpvpaper_slideshow_pid"

if [[ -f "$pidFile" ]]; then
    kill -SIGUSR1 "$(cat "$pidFile")"
    echo "Triggered next wallpaper."
else
    echo "Slideshow script not running. Start it first, dumbass."
fi
