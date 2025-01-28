#!/bin/sh

tab='	'
IFS="$tab"

result="$(~/.config/scripts/drun-fzf/parse-desktop-files.py | fzf \
  --no-clear \
  --with-nth 1..2 \
  --nth 1..2 \
  --delimiter "$tab")"

[ -z "$result" ] && exit
set -- $result
filepath="$3"

run-desktop-file "$filepath"

