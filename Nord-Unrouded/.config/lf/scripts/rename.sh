#!/usr/bin/env bash

export _script_name="rename"

# shellcheck source=/home/heather/.config/lf/scripts/common-defs.sh
source ~/.config/lf/scripts/common-defs.sh

if [ -z "$f" ]; then die "no file selected"; fi
file="$f"

old_name="$(basename "$file")"
new_name="$(read_line "new name: " "$old_name")"
if [ -n "$new_name" ] && [ "$new_name" != "$old_name" ]; then
  dir_name="$(dirname "$file")"
  mv -v "$file" "${dir_name}/${new_name}" && :reload && :select "${dir_name}/${new_name}"
fi

