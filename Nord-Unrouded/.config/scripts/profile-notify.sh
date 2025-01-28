#!/usr/bin/env bash

# Monitors profile_file for changes and
# sends desktop notifications on every change
profile_file='/sys/firmware/acpi/platform_profile'

if [ ! -e "$profile_file" ]; then
  echo "[profile-notify.sh] No file $profile_file, exiting" >&2
  exit 1
fi

inotifywait -mqe modify "$profile_file" | while read fname event; do
  notify-send -t 3000 'Platform profile changed' "Current profile: $(cat "$profile_file")"
done

