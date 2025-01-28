#!/bin/sh

tab='	'
IFS="$tab"

selected="$(fzf -d "$tab" <~/.config/scripts/unicode-picker/unicode_list.txt)"
[ -z "$selected" ] && exit

set -- $selected
char="$1"
name="$2"

wl-copy -t "text/plain;charset=utf-8" "$char"
