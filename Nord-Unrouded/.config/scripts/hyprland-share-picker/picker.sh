#!/bin/sh

if [ -n "$1" ]; then
    out_file="$1"
else
    out_file=/dev/stdout
fi

tmpfile="$(mktemp)"
[ -z "$tmpfile" ] && exit 1

printf '%s\n' "$XDPH_WINDOW_SHARING_LIST" | sed -Ee 's/(^)([0-9]+)\[HC>\]/\2\tW\t/g;s/([0-9]+)\[HC>\]/\n\1\tW\t/g;s/\[HT>\]/\t/g;s/\[HE>\]//g' >"$tmpfile"
hyprctl monitors | awk '/^Monitor/ {print "_\tM\t" $2}' >>"$tmpfile"
printf '_\tR\tSelect region with slurp\n' >>"$tmpfile"

result="$(fzf \
    --delimiter "$(printf '\t')" \
    --with-nth '2..' \
    --nth '1..' \
    --no-clear \
    --no-multi <"$tmpfile")"
rm "$tmpfile"

[ -z "$result" ] && exit 0

set -- $result
window_id="$1"
selection_type="$2"
monitor="$3"

case "$selection_type" in
    W)
        result="$(printf 'W\t%d' "$window_id")"
        ;;
    M)
        result="$(printf 'M\t%s' "$monitor")"
        ;;
    R)
        result="$(printf 'R')"
        ;;
esac

printf '%s\n' "$result" >"$out_file"

