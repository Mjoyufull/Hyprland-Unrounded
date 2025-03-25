#!/usr/bin/env bash

export _script_name="make-file"

# shellcheck source=/home/heather/.config/lf/scripts/common-defs.sh
source ~/.config/lf/scripts/common-defs.sh

name="$(read_line "file name: ")"

if [ ! $? = 0 ]; then
  exit
fi

if [ -z "$name" ]; then
  echo_info "empty file name"
elif [ -e "$name" ]; then
  die "$name already exists"
else
  touch "$name" && :reload && :select "$(realpath "$name")"
fi

