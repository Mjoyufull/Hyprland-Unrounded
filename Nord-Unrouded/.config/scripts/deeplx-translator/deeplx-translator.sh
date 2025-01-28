#!/usr/bin/env bash

cleanup() {
    kill $(jobs -p) 2>/dev/null
    [ -n "$tmpfile" ] && rm "$tmpfile" 2>/dev/null
    [ -n "$fifo_path" ] && rm "$fifo_path" 2>/dev/null
}
trap cleanup EXIT ERR TERM INT
die() {
  printf '\033[31m%s\033[0m\n' "$1"
  cleanup
  exit 1
}

command -v deeplx >/dev/null || die "deeplx is not installed"

deeplx 1>/dev/null 2>&1&
sleep 0.1

tmpfile="$(mktemp)"
[ -z "$tmpfile" ] && die "unable to create tmpfile"

cat >"$tmpfile" <<EOF
SRC_LANG: auto
DST_LANG: RU
======================
Enter your text...
======================
Translation will appear here
EOF

sock_path="$(mktemp -u)"
nvim --listen "$sock_path" \
    -c 'nnoremap <ESC> :q!<CR>' \
    -c 'nnoremap <CR> :w<CR>' \
    -c "set nowritebackup noswapfile" \
    "$tmpfile" &
editor_pid="$!"

{
while true; do
    inotifywait -qqe modify "$tmpfile"

    # the most cursed shell code I've ever written
    src_lang="$(head -n 1 "$tmpfile" \
        | awk -F ': ' -e '/^SRC_LANG: .*$/ {print toupper($2); exit}')"
    [ -z "$src_lang" ] && die "unable to determine source language"
    tgt_lang="$(tail -n +2 "$tmpfile" | head -n 1 \
        | awk -F ': ' -e '/^DST_LANG: .*$/ {print toupper($2); exit}')"
    [ -z "$tgt_lang" ] && die "unable to determine target language"
    query="$(awk -e 'BEGIN {started=0} /^=*$/ {if (started == 0) {started=1} else {exit}} {if (started == 1) {started=2} else if (started == 2) {print}}' "$tmpfile")"
    [ -z "$query" ] && die "empty query"

    # construct json request to deeplx server
    request_data="$(jq -ncM \
      --arg text "$query" \
      --arg src_lang "$src_lang" \
      --arg tgt_lang "$tgt_lang" \
      '{"text": $text, "source_lang": $src_lang, "target_lang": $tgt_lang}')"
    [ -z "$request_data" ] && die "faild to construct request"

    response="$(curl -s \
      -X POST http://localhost:1188/translate \
      -H "Content-Type: application/json" \
      -d "$request_data")"
    [ -z "$response" ] && die "didnt get response from server"

    translation="$(printf '%s' "$response" | jq -r '.data')"
    alternatives="$(printf '%s' "$response" | jq -r '.alternatives[]')"

    # clear prev translation
    sed -i '/^=*$/{n;:a;n;/^=*$/{q};ba}' "$tmpfile" || die "sed error"

    if [ "$translation" = 'null' ]; then
        printf '%s' "$response" >>"$tmpfile"
    elif [ -z "$alternatives" ]; then
        printf '%s' "$translation" >>"$tmpfile"
    else
        printf '%s\n\nAlternatives:\n%s' "$translation" "$alternatives" >>"$tmpfile"
    fi

    nvim --server "$sock_path" --remote-send '<C-\><C-N>:e!<CR>'
done;
} 1>/dev/null 2>/dev/null &
translator_pid="$!"

wait -n "$editor_pid" "$translator_pid"

cleanup

