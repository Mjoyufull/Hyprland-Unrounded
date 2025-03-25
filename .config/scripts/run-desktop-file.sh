#!/bin/sh

if [ -z "$1" ]; then
  echo "you need to specify full path to desktop file or its name"
  exit 1
fi

filename="$(realpath "$1")"
if [ ! -f "$filename" ]; then
  # try to search for desktop file ourselves if provided path does not exist
  filename="$(find ~/.local/share/applications/ /usr/share/applications/ -maxdepth 1 -type f -name "$1" -print -quit)"
  if [ -z "$filename" ]; then
    echo "$1 not found in ~/.local/share/applications/ /usr/share/applications/"
    exit 1
  fi
fi

is_term="$(grep -m1 -o -Pe '(?<=^Terminal\=).*' "${filename}")"
exec_line="$(grep -m1 -o -Pe '(?<=^Exec\=).*' "${filename}" | sed 's/%[fFuUdDnNickvm]//g')"

if [ -z "$exec_line" ]; then
  echo "exec line not found in $filename"
  exit 1
fi

# we will append all extra args after exec_line
shift 1

if [ -n "$HYPRLAND_INSTANCE_SIGNATURE" ]; then
  if [ "$is_term" = "true" ]; then
    hyprctl dispatch exec -- foot -- $exec_line "$@" >/dev/null
  else
    hyprctl dispatch exec -- $exec_line "$@" >/dev/null
  fi
else
  if [ "$is_term" = "true" ]; then
    swaymsg exec -- foot -- $exec_line "$@" >/dev/null
  else
    swaymsg exec -- $exec_line "$@" >/dev/null
  fi
fi

