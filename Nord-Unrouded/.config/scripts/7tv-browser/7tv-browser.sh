#!/usr/bin/env bash

cleanup() {
    [ -n "${SEVENTV_BROWSER_TMPDIR}" ] && rm -rf "${SEVENTV_BROWSER_TMPDIR}"
}
trap cleanup ERR EXIT INT TERM HUP

die() {
    printf '\033[31;1mX %s\033[0m\n' "$1"
    cleanup
    exit 1
}

SEVENTV_BROWSER_TMPDIR="$(mktemp -dt 7tv-browser-tmpdir.XXXXXX)"
[ -z "${SEVENTV_BROWSER_TMPDIR}" ] && die "creating tmpdir failed"
export SEVENTV_BROWSER_TMPDIR

export FZF_DEFAULT_COMMAND='true' # noop
fzf \
  --with-shell 'bash -c' \
  --bind "ctrl-r:reload:~/.config/scripts/7tv-browser/fetch-emote-list.sh {q}" \
  --bind 'ctrl-p:execute-silent:name={1}; id={2}; url={3}; cache_dir=~/.cache/7tv-browser/; extension="${url##*.}"; filename="${name}_${id}.${extension}"; filepath="${cache_dir}/${filename}"; wl-copy "${filepath}"' \
  --bind 'ctrl-y:execute-silent:name={1}; id={2}; url={3}; cache_dir=~/.cache/7tv-browser/; extension="${url##*.}"; filename="${name}_${id}.${extension}"; filepath="${cache_dir}/${filename}"; cat "${filepath}" | wl-copy' \
  --bind 'enter:execute-silent(name={1}; id={2}; url={3}; cache_dir=~/.cache/7tv-browser/; extension="${url##*.}"; filename="${name}_${id}.${extension}"; filepath="${cache_dir}/${filename}"; cat "${filepath}" | wl-copy)+abort' \
  --preview "/home/heather/.config/scripts/7tv-browser/preview.sh {1} {2} {3}" \
  --nth '1' \
  --with-nth '1' \
  --delimiter $'\t' \
  --header 'CTRL+R to fetch results' \
  --preview-label 'CTRL+P copy path, CTRL+Y copy image' \
  --preview-label-pos bottom

cleanup

