#!/bin/sh

tmpfile="$(mktemp)"
printf "Search the Internet for...\n" >"$tmpfile"

nvim \
    -c 'nnoremap <ESC> :q!<CR>' \
    -c 'nnoremap <CR> :wq<CR>' \
    -c 'call feedkeys("o")' \
    "$tmpfile"
query="$(sed -e '1d;/^$/d;s/ /+/g' "$tmpfile" | tr '\n' '+')"

if [ -n "$query" ]; then
    engine='https://duckduckgo.com/?t=ffab&q='
    open-in-browser "${engine}${query}"
fi

rm "$tmpfile"

