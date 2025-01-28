#!/bin/sh

tab='	'
IFS="$tab"

selected="$(fzf -d "$tab" <~/.config/scripts/emoji-picker/emoji-list.txt)"
[ -z "$selected" ] && exit

set -- $selected
emoji="$1"
description="$2"

printf '%s' "$emoji" | wl-copy -t "text/plain;charset=utf-8"
