#!/usr/bin/env bash

[ -n "$OLDTERM" ] && export TERM="$OLDTERM"

filename="$(realpath "$1")"

# first match based on extension
case "${filename,,}" in
  *.png|*.jpeg|*.jpg|*.jxl|*.webp|*.gif)
      exec mvi "$filename";;
  *.mp3|*.flac|*.opus|*.wav|*.ape)
      exec mpv --no-video "$filename";;
  *.mkv|*.mp4)
      exec mpv --force-window=immediate "$filename";;
  *.webm) # can be either video or music, so dont force window
      exec mpv "$filename";;
  *.djvu|*.pdf)
      exec zathura "$filename";;
esac

# match based on mime type
mime_description=$(file --brief --mime -- "$filename")
case "$mime_description" in
  image/*)
    exec mvi "$filename"
    ;;
  video/*)
    exec mpv --force-window=immediate "$filename"
    ;;
  audio/*)
    exec mpv --no-video "$filename"
esac

if [[ "$mime_description" =~ charset= ]] && [[ ! "$mime_description" =~ charset=binary ]]; then
  exec "${EDITOR:-vi}" "$filename"
fi

exec xdg-open "$filename"

