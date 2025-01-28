#!/usr/bin/env bash

export _script_name="make-symlink"

# shellcheck source=/home/heather/.config/lf/scripts/common-defs.sh
source ~/.config/lf/scripts/common-defs.sh

# TODO: make both prompts appear in the same tmux popup
name="$(read_line "link name: ")"
if [ ! $? = 0 ]; then exit; fi

if [ -z "$name" ]; then
  echo_info "empty link name"
else
  target="$(read_line "link target: ")"
  if [ -z "$target" ]; then
    echo_info "empty link target"
  else
    ln -sv "$target" "$name" && :reload && :select "$(realpath "$name")"
  fi
fi

