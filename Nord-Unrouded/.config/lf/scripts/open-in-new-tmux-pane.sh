#!/usr/bin/env bash

export _script_name="open-in-new-tmux-pane"

# shellcheck source=/home/heather/.config/lf/scripts/common-defs.sh
source ~/.config/lf/scripts/common-defs.sh

if [ -z "$TMUX" ]; then
    die "TMUX is not set; not running in tmux?"
fi

~/.config/lf/scripts/tmux-popup.sh -h 2 -E -- sh -c '
    echo "input direction (h/j/k/l)"
    chr="$(~/.config/lf/scripts/read-single-char.sh)"
    case "$chr" in
        h)
            exit 81 ;;
        j)
            exit 82 ;;
        k)
            exit 83 ;;
        l)
            exit 84 ;;
        *)
            exit 1 ;;
    esac
    '
dir_num="$?"

case "$dir_num" in
    81)
        dir="left"
        dir_arg="-h"
        pos_arg="-b"
        ;;
    82)
        dir="down"
        dir_arg="-v"
        ;;
    83)
        dir="up"
        dir_arg="-v"
        pos_arg="-b"
        ;;
    84)
        dir="right"
        dir_arg="-h"
        ;;
    *)
        die "failed to read direction" ;;
esac

tmux split-window $dir_arg $pos_arg "$@"

