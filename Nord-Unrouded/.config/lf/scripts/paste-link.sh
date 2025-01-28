#!/usr/bin/env bash

export _script_name="paste-link"

# shellcheck source=/home/heather/.config/lf/scripts/common-defs.sh
source ~/.config/lf/scripts/common-defs.sh
  
# busybox ln doesn't support -t and -r flags
if detect_busybox; then
  die "busybox ln won't work, do it manually"
fi

link_type="$1"
if [ ! "$link_type" = "hard" ] && [ ! "$link_type" = "symbolic" ]; then
  die "wrong link type: $link_type"
fi
if [ "$link_type" = "symbolic" ]; then
  relative="$2"
  if [ ! "$relative" = "absolute" ] && [ ! "$relative" = "relative" ]; then
    die "wrong link type: $relative"
  fi
fi

buffer_file="${_lf_data_dir}/files"
if [ ! -f "$buffer_file" ]; then
  die "$buffer_file does not exist"
fi

# read list of selected files
declare -a files
while IFS= read -r line; do
  files+=("$line")
done < <(tail "$buffer_file" -n +2)
if [ ${#files[@]} -eq 0 ]; then die "no files in buffer"; fi

# where to create links
target_dir="$PWD"
if [ ! -d "$target_dir" ]; then die "$target_dir is not a directory"; fi

if [ "$link_type" = "hard" ]; then
  link_command() {
    ln -v -t "$target_dir" -- "${files[@]}"
    return "$?"
  }
elif [ "$link_type" = "symbolic" ] && [ "$relative" = "absolute" ]; then
  link_command() {
    ln -v -s -t "$target_dir" -- "${files[@]}"
    return "$?"
  }
elif [ "$link_type" = "symbolic" ] && [ "$relative" = "relative" ]; then
  link_command() {
    ln -v -s -r -t "$target_dir" -- "${files[@]}"
    return "$?"
  }
else
  die "wrong options: $link_type $relative"
fi

if stderr_wrapper link_command; then :reload; :clear; fi

