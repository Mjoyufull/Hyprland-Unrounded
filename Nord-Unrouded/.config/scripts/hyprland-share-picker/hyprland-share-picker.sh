#!/bin/sh

tmpfile="$(mktemp)"
[ -z "$tmpfile" ] && exit 1

foot-popup \
    env XDPH_WINDOW_SHARING_LIST="$XDPH_WINDOW_SHARING_LIST" \
    ~/.config/scripts/hyprland-share-picker/picker.sh "$tmpfile"

result="$(cat "$tmpfile")"
rm "$tmpfile"

set -- $result
selection_type="$1"
arg="$2"

# EDIT THIS
restore_token_flag="r"

case "$selection_type" in
    W)
        result="$(printf '[SELECTION]%s/window:%d' "$restore_token_flag" "$arg")"
        ;;
    M)
        result="$(printf '[SELECTION]%s/screen:%s' "$restore_token_flag" "$arg")"
        ;;
    R)
        region="$(slurp -f '%o@%x,%y,%w,%h')"
        if [ -z "$region" ]; then
            resut="$(printf 'error1')"
        else
            result="$(printf '[SELECTION]%s/region:%s' "$restore_token_flag" "$region")"
        fi
        ;;
esac

printf '%s\n' "$result"

