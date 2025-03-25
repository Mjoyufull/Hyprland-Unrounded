#!/usr/bin/env bash

export _script_name="add-hook"

# shellcheck source=/home/heather/.config/lf/scripts/common-defs.sh
source ~/.config/lf/scripts/common-defs.sh

# $1 is hook name
hook_name="$1"
# $2 is hook script 
hook_sript="$2"
if [ -z "$hook_sript" ]; then die "empty hook"; fi

case "$hook_name" in
pre-cd)
  true
  ;;
on-cd)
  true
  ;;
on-select)
  true
  ;;
on-redraw)
  true
  ;;
on-quit)
  true
  ;;
*)
  die "wrong hook: $hook_name"
  ;;
esac

hooks_dir="${_lf_client_data_dir}/${hook_name}/"
if [ ! -d "$hooks_dir" ]; then
  mkdir "$hooks_dir" || die "can't create directory $hooks_dir"
fi

hook_file_path="${hooks_dir}/hook_${RANDOM}.sh"
echo "_self_path=$(printf '%q' "$hook_file_path");" >"$hook_file_path"
echo "$hook_sript" >>"$hook_file_path"

lf -remote "send $id cmd $hook_name &~/.config/lf/scripts/run-hooks.sh $hook_name"

