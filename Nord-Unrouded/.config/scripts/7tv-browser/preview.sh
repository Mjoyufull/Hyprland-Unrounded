#!/usr/bin/env bash

set -o pipefail

cleanup() {
    [ -n "$tmpdir" ] && rm -rf "$tmpdir"
}
trap cleanup ERR EXIT INT TERM HUP

die() {
    printf '\033[31;1mX %s\033[0m\n' "$1"
    cleanup
    exit 1
}

msg() {
    printf '> %s\n' "$1"
}

clear() {
    printf "\033[2J"
}

do_chafa() {
    chafa -f sixels -O 9 --view-size "${FZF_PREVIEW_COLUMNS}x${FZF_PREVIEW_LINES}" "$@"
}

[ -z "${SEVENTV_BROWSER_TMPDIR}" ] && die "7TV_BROWSER_TMPDIR is unset"
tmpdir="${SEVENTV_BROWSER_TMPDIR}/${$}"
mkdir -p "$tmpdir" || die "create ${tmpdir} failed"

cache_dir=~/.cache/7tv-browser

name="$1"
id="$2"
url="$3"
[ -z "$name" ] || [ -z "$id" ] || [ -z "$url" ] && die "not enough args"

extension="${url##*.}"
filename="${name}_${id}.${extension}"
filepath="${cache_dir}/${filename}"

if [ ! -f "$filepath" ]; then
    msg "cache miss, fetching from 7tv..."
    if ! curl -sS --fail-with-body "$url" >"$filepath"; then
        rm "$filepath"
        die "fetch emote file failed"
    fi
else
    msg "found cached emote file"
fi

frame_count="$(magick identify "$filepath" | wc -l)"
if [ "$frame_count" -lt 1 ]; then
    die "get number of frames in image failed"
elif [ "$frame_count" -eq 1 ]; then
    msg "emote is static image"
    clear
    do_chafa --scale max "$filepath"
else
    msg "emote is animated"

    msg "extracting frames..."
    magick "$filepath" -coalesce "${tmpdir}/frame%06d.jpg" || die "extract frames failed"

    clear
    while true; do
        for i in "${tmpdir}"/*; do
            do_chafa --scale max "$i"
            clear
        done
    done
fi

cleanup

