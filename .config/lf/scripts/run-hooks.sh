#!/usr/bin/env bash

export _script_name="run-hooks"

# shellcheck source=/home/heather/.config/lf/scripts/common-defs.sh
source ~/.config/lf/scripts/common-defs.sh

# $1 is hook name
hook_name="$1"
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
if [ ! -d "$hooks_dir" ]; then exit 0; fi

# wait for lock to be gone
if [ -f "${_lf_client_data_dir}/hook.lock" ]; then
  # wait for file to be deleted, doesn't work on busybox
  tail --follow=name "${_lf_client_data_dir}/hook.lock"
fi
touch "${_lf_client_data_dir}/hook.lock"
# run newest hooks first
for fname in $(ls -t "$hooks_dir"); do
  bash "${hooks_dir}/${fname}"
done
rm "${_lf_client_data_dir}/hook.lock"

