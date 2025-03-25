#!/usr/bin/env bash

export _script_name="delete"

# shellcheck source=/home/heather/.config/lf/scripts/common-defs.sh
source ~/.config/lf/scripts/common-defs.sh

# Die if there are no selected files; yes, it can happen
if [ -z "$fx" ]; then die "no files selected"; fi

# Generate name for trash subdir (current datetime)
dir="$(date '+%Y-%m-%dT%H:%M:%S')"
if [ -z "$dir" ]; then die "failed to get current time"; fi
trash_dir=~/.local/share/Trash/"$dir"

# Determine if trash will be used
# If file is not under HOME, don't use trash
# (maybe check if files are on the same fs instead?)
if echo "$fx" | grep -qvEe "^${HOME}.*$"; then
  echo_warn "not using trash"
  use_trash=0
else
  use_trash=1
  # don't use --backup option with busybox coreutils
  if detect_busybox; then
    if ask_warn '--backup not supported, possible overwrite; continue?' 'Y'; then :; else
      die "abort"
    fi
    backup_arg=''
  else
    backup_arg='--backup=numbered'
  fi
fi

# Command that will be called to delete files depends on
# whether we using trash or not
if [ "$use_trash" = 1 ]; then
  delete_command() {
    mkdir -p "$trash_dir" || die "failed to create $dir"
    mv -v $backup_arg -t "$trash_dir" -- $fx
    return $?
  }
else
  delete_command() {
    rm -vrf $fx
    return $?
  }
fi

# Don't confirm deletion if only 1 file is selected
# But still confirm deletion if not using trash
file_count="$(echo "$fx" | wc -l)"
if [ "$file_count" = 1 ]; then
  if [ "$use_trash" = 1 ]; then
    if stderr_wrapper delete_command; then :unselect; fi
  else
    if ask_warn "not using trash, delete anyway?" "N"; then
      if stderr_wrapper delete_command; then :unselect; fi
    else
      die "aborted by user"
    fi
  fi
  exit 
fi

if ask "delete $file_count files?" "Y"; then
  if stderr_wrapper delete_command; then :unselect; fi
else
  die "abort"
fi

:reload

