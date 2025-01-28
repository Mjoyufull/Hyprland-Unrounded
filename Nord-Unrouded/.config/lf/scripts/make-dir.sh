#!/usr/bin/env bash

export _script_name="make-dir"

# shellcheck source=/home/heather/.config/lf/scripts/common-defs.sh
source ~/.config/lf/scripts/common-defs.sh

name="$(read_line "dir name: ")"

if [ ! $? = 0 ]; then
  exit
fi

if [ -z "$name" ]; then
  echo_info "empty directory name"
else
  mkdir -pv "$name" && :reload && :select "$(realpath "$name")"
fi

