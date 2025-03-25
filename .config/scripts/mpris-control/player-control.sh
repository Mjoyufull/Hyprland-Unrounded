#!/usr/bin/env bash

# ok so how this shit works:
# it launches playerctl command that watches for changes
# every time there's a change it sends fzf an event
# fzf then executes omega cursed preview command
# aint going to explain how it works but yeah
#
# depends on curl, fzf, playerctl, chafa, bash (duh)

cleanup() {
    rm -f /tmp/player-control-fzf-port
    kill "$fzf_pid" 2>/dev/null
    kill "$read_pid" 2>/dev/null
    kill $(jobs -l | awk '{print $2}') 2>/dev/null
}
trap cleanup INT HUP TERM ERR EXIT

export FZF_API_KEY="$(head -c 32 /dev/urandom 2>&1 | base64)"
export FZF_DEFAULT_COMMAND='true' # noop

preview_cmd=$(
cat <<'EOF'
[ -z {} ] && exit;
md="$(playerctl -p {} metadata)";
art="$(echo "$md" | awk '$2 == "mpris:artUrl" {print $3}')";
if [ -n "$art" ]; then
    if echo "$art" | grep -q 'base64'; then
        echo "$art" | cut -d ',' -f 2- | base64 -d | chafa -s "${FZF_PREVIEW_COLUMNS}x$((FZF_PREVIEW_LINES / 2))" --align hcenter -f sixel;
    else
        art="${art#file://}";
        : "${art//+/ }"; printf -v art_dec '%b' "${_//%/\\x}";
        chafa -s "${FZF_PREVIEW_COLUMNS}x$((FZF_PREVIEW_LINES / 2))" --align hcenter -f sixel "$art_dec";
    fi;
fi;
echo "$md" | awk '$3 != "" && $2 != "mpris:artUrl" && $2 != "xesam:url" { sub(/^.+?:/, "", $2); printf $2"\t"; for ( i=3;i<=NF;i++ ) { printf $i""FS }; printf "\n" }';
EOF
)

fzf \
    --listen 127.0.0.1:0 \
    --bind 'start:execute-silent:echo $FZF_PORT >/tmp/player-control-fzf-port' \
    --disabled \
    --with-shell 'bash -c' \
    --preview "$preview_cmd" \
    --preview-window 'right,65%' \
    --tabstop 8 \
    --preview-label 'SPACE to play/pause, < and > to prev/next' \
    --preview-label-pos bottom \
    --bind 'space:execute-silent:playerctl -p {} play-pause' \
    --bind '>:execute-silent:playerctl -p {} next' \
    --bind '<:execute-silent:playerctl -p {} previous' \
    &
fzf_pid="$!"

while [ -z "$FZF_PORT" ]; do
    sleep 0.1
    FZF_PORT="$(cat /tmp/player-control-fzf-port)"
done

playerctl -Faf '{{title}}' metadata | while read -r dummy; do
    curl -X POST \
        -H "x-api-key: ${FZF_API_KEY}" \
        -d 'reload:playerctl -al' \
        127.0.0.1:"${FZF_PORT}"
done &
read_pid="$!"

wait -n "$fzf_pid" "$read_pid"

cleanup

