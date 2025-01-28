#!/usr/bin/env bash

export _script_name="unarchive"

# shellcheck source=/home/heather/.config/lf/scripts/common-defs.sh
source ~/.config/lf/scripts/common-defs.sh

extract_to_subdir=0
if [ "$1" = "-s" ]; then
    extract_to_subdir=1
    shift 1
fi

[ -z "$1" ] && die "no file selected"
file="$1"

tar_exe="$(command -v bsdtar || command -v tar)"
if [ -z "$tar_exe" ]; then
    die "tar executable not found"
fi

if [ "$extract_to_subdir" = 0 ]; then
    stderr_wrapper "$tar_exe" -x -f "$file"
else
    destdir="${file%.*}"
    destdir="${destdir%.tar}"
    if [ -e "$destdir" ]; then
        die "${destdir} already exists"
    fi

    mkdir "$destdir" || die "unable to create ${destdir}"
    stderr_wrapper "$tar_exe" -x -C "$destdir" -f "$file" || { rmdir "$destdir"; exit; }
    :select "$destdir"
fi


