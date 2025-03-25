#!/bin/bash
pidFile="/tmp/mpvpaper_slideshow_pid"

if [[ -f "$pidFile" ]]; then
    kill -SIGUSR2 "$(cat "$pidFile")"
    echo "Triggered previous wallpaper."
else
    echo "Slideshow script not running. Can't go back in time, genius."
fi
