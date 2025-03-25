#!/usr/bin/env bash

id="$1"
mime="$2"
preview="$3"

# open links in firefox
if [[ "$preview" =~ ^https?:\/\/ ]]; then
  open-in-browser "$(cclip get "$id")"
# open images in imv
elif [[ "$mime" =~ image/.* ]]; then
  tmp_file="/tmp/imv_stdin_$$"
  cclip get "$id" >"$tmp_file"
  # Don't ask me what this :; does. I don't know why, but without it it doesn't work
  hyprctl dispatch exec -- sh -c ":; imv -w FLOATME '${tmp_file}'; rm '${tmp_file}'"
# open text in nvim
else
  tmp_file="/tmp/nvim_stdin_$$"
  cclip get "$id" >"$tmp_file"
  hyprctl dispatch exec -- sh -c ":; foot --title foot-float nvim ${tmp_file}; rm ${tmp_file}"
fi

