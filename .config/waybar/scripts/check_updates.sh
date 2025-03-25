#!/bin/bash

while true; do
    updates="$(checkupdates | wc -l)" # Get the number of available updates

    # Output a valid JSON object
    if [ "$updates" -eq 0 ]; then
        echo '{"text": "󰂪", "tooltip": "System is up to date"}'
    else
        echo "{\"text\": \"$updates 󱍷\", \"tooltip\": \"$updates updates available\"}"
    fi

    sleep 3600  # Sleep for 1 hour (3600 seconds) before running again
done

