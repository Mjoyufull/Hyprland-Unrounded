#!/bin/sh

list_cmd="cclip list rowid,mime_type,timestamp,preview"
export FZF_DEFAULT_COMMAND="$list_cmd"

fzf \
  --ignore-case \
  --no-multi \
  --with-nth 4 \
  --delimiter "$(printf '\t')" \
  --scheme history \
  --no-clear \
  --preview 'exec ~/.config/scripts/cclip-fzf/previewer.sh {}' \
  --bind 'focus:transform-preview-label:date -d @{3} "+%a, %d %b %Y %H:%M:%S %Z"' \
  --preview-label-pos bottom \
  --bind "ctrl-o:become(~/.config/scripts/cclip-fzf/opener.sh {1} {2} {4})" \
  --bind "ctrl-x:execute-silent(cclip delete -s {1})+reload(${list_cmd})" \
  --bind "ctrl-r:reload(${list_cmd})" \
  --bind "enter:become(cclip get {1} | wl-copy -t {2}; sleep 0.05)"
  # DO NOT REMOVE sleep 0.05 EVERYTHING BREAKS WITHOUT IT

