#!/bin/sh

# Usage: tmux-popup.sh [-w WIDTH] [-h HEIGHT] [-E] [ARGS] -- COMMAND
#
# Display tmux popup running COMMAND centered in currently active pane
#
# WIDTH and HEIGHT can end with %, in this case they are treated
# as percentage of pane size
#
# It is IMPORTANT to separate command from args with --
# that's just how my stupid aah parser works

if [ -z "$TMUX" ]; then
  die "TMUX envvar is not set, not running in tmux?"
fi

height="70%"
width="70%"
e_count=0
extra_args=""

# Parse command line options
while true; do
  case "$1" in
    '-w')
      shift 1
      width="$1"
      ;;
    '-h')
      shift 1
      height="$1"
      ;;
    '-E')
      e_count=$((e_count + 1))
      ;;
    '-EE')
      e_flag="-EE"
      ;;
    '--')
      shift 1
      break
      ;;
    *)
      die "wrong option: $1"
      ;;
  esac
  shift 1
done

if [ -z "$e_flag" ]; then
  if [ "$e_count" -ge 2 ]; then
    e_flag="-EE"
  elif [ "$e_count" -eq 1 ]; then
    e_flag="-E"
  fi
fi

popup_border_lines=$(tmux show-options -Apv popup-border-lines)
case "$width" in
  *%) w_percent=1 ;;
  *)
    if [ ! "$popup_border_lines" = "none" ]; then
      width=$((width + 2))
    fi
    w_percent=0
    ;;
esac

case "$height" in
  *%) h_percent=1 ;;
  *)
    if [ ! "$popup_border_lines" = "none" ]; then
      height=$((height + 2))
    fi
    h_percent=0
    ;;
esac

tmux_output=$(tmux display-message -p "#{pane_left} #{pane_right} #{pane_top} #{pane_bottom} #{pane_width} #{pane_height}")
pane_left=$(echo "$tmux_output" | cut -d' ' -f1)
pane_right=$(echo "$tmux_output" | cut -d' ' -f2)
pane_top=$(echo "$tmux_output" | cut -d' ' -f3)
pane_bottom=$(echo "$tmux_output" | cut -d' ' -f4)
pane_width=$(echo "$tmux_output" | cut -d' ' -f5)
pane_height=$(echo "$tmux_output" | cut -d' ' -f6)

pane_center_x=$(((pane_left + pane_right) / 2))
pane_center_y=$(((pane_top + pane_bottom) / 2))

if [ "$w_percent" -eq 1 ]; then
  popup_width=$((${width%\%} * pane_width / 100))
else
  popup_width=${width%\%}
fi

if [ "$h_percent" -eq 1 ]; then
  popup_height=$((${height%\%} * pane_height / 100))
else
  popup_height=${height%\%}
fi

x=$((pane_center_x - popup_width / 2))
y=$((pane_center_y + popup_height / 2))
w=$popup_width
h=$popup_height

tmux display-popup \
  -e id="$id" \
  -e LF_DATA_HOME="$LF_DATA_HOME" \
  -x "$x" \
  -y "$y" \
  -w "$w" \
  -h "$h" \
  $e_flag -- \
  "$@"
