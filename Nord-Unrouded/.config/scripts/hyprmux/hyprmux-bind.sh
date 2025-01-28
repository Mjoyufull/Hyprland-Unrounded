#!/usr/bin/env bash
# hyprmux - bind a hyprland window to a tmux pane
# was slapped together in 3 days, things might break
#
# notable omissions:
#   1. it does not handle moving tmux pane to a different tmux window (too much work, just unbind and bind again)
#   2. it does not handle moving tmux hyprland window to a different workspace (doable, but can't be bothered for now)
#   3. offset and position of target window are hardcoded (calculate them each time hook is called?)

echo_error() {
  printf "\033[31m%s\033[0m\n" "$@"
}

echo_success() {
  printf "\033[32m%s\033[0m\n" "$@"
}

echo_important() {
  printf "\033[1m%s\033[0m\n" "$@"
}

# Determine the window the script is being launched from (`target` window)
# we just take active window and assume it's the window where tmux is running
target_hyprland_window_address="$(hyprctl activewindow -j | jq -r '.address')"
target_hyprland_window_ws_id="$(hyprctl clients -j | jq -r ".[] | select(.address == \"$target_hyprland_window_address\") | .workspace.id")"

# Pick `source` window - window that will be inside a tmux pane
IFS=$'\t' read -r source_hyprland_window_title source_hyprland_window_address < <(hyprctl clients -j | jq -r ".[] | select(.address != \"$target_hyprland_window_address\") | \"\(.title)\t\(.address)\"" | fzf)
if [ -z "$source_hyprland_window_address" ]; then
  exit 1
fi

# `target` tmux window and pane are those active when this script is called
read -r target_tmux_pane_id target_tmux_window_id < <(tmux display-message -p "#{pane_id} #{window_id}")

echo_important "source and target data"
echo "target_hyprland_window_address: $target_hyprland_window_address"
echo "target_hyprland_window_ws_id: $target_hyprland_window_ws_id"
echo "target_tmux_pane_id: $target_tmux_pane_id"
echo "target_tmux_window_id: $target_tmux_window_id"
echo "source_hyprland_window_address: $source_hyprland_window_address"

# array of all tmux hooks we will be listening to, they are set up in a loop later
hooks=("window-layout-changed" "after-new-window" "after-select-window" "window-unlinked" "after-select-pane")

# check if there are hooks for this source window already
if tmux show-hooks | grep -qe "$source_hyprland_window_address" || \
    tmux show-hook -w | grep -qe "$source_hyprland_window_address" || \
    tmux show-hook -p | grep -qe "$source_hyprland_window_address"; then
  echo_error "there are hooks already configured for this source window, exiting"
  exit 1
fi

setup-hooks() {
  # Loop through hooks array and set up each hook to execute `hyprmux-hook` script
  # argv for hyprmux-hook:
  #   hook_name
  #   target_tmux_pane_id
  #   target_tmux_window_id
  #   source_hyprland_window_address
  #   target_hyprland_window_address
  echo_important "setting up hooks"
  # I have severe brain damage
  # tmux hook system is very cringe, if we just create another hook it deletes all hooks
  # with the same name
  # 
  # instead, we list all hooks with the same name and find highest index using this cursed grep
  # and then increment id by one
  #
  # first we search for pane-specific hooks, then for window-specific, then for global
  # (TODO: instead of global, use session id (if its even doable lol))
  for hook in "${hooks[@]}"; do
    hook_index="$(tmux show-hooks -p -t "$target_tmux_pane_id" | \
                  grep -oPe "(?<=^$hook\[)[0-9]+(?=\])" | sort -r | head -n 1)"
    if [ -z "$hook_index" ]; then
      hook_index="$(tmux show-hooks -w -t "$target_tmux_window_id" | \
                    grep -oPe "(?<=^$hook\[)[0-9]+(?=\])" | sort -r | head -n 1)"
    fi
    if [ -z "$hook_index" ]; then
      hook_index="$(tmux show-hooks | \
                    grep -oPe "(?<=^$hook\[)[0-9]+(?=\])" | sort -r | head -n 1)"
    fi
    if [ -z "$hook_index" ]; then
      hook_index=0
      hook="${hook}[0]"
    else
      hook="${hook}[$(( hook_index + 1 ))]"
    fi
    printf "%s... " "$hook"
    
    tmux set-hook \
      -p -t "$target_tmux_pane_id" \
      -w -t "$target_tmux_window_id" \
      "$hook" \
      "run-shell -b 'exec ~/.config/scripts/hyprmux/hyprmux-hook.sh #{hook} $target_tmux_pane_id $target_tmux_window_id $source_hyprland_window_address $target_hyprland_window_address >/dev/null'" && echo_success "ok"
  done
}

reset-hooks() {
  # complication here is to remove only those hooks this script owns
  # we check which hooks have matching source_hyprland_window_address in their command line
  # since it's impossible to have hooks with the same source_hyprland_window_address for 
  # different panes/windows/whatever (hyprmux-bind won't let you do it)
  echo_important "removing hooks"
  for hook in $(tmux show-hooks | grep -e "$source_hyprland_window_address" | cut -f 1 -d ' '); do
    printf "%s... " "$hook"
    tmux set-hook -u "$hook" && echo_success "ok"
  done
  for hook in $(tmux show-hooks -w | grep -e "$source_hyprland_window_address" | cut -f 1 -d ' '); do
    printf "%s... " "$hook"
    tmux set-hook -w -u "$hook" && echo_success "ok"
  done
  for hook in $(tmux show-hooks -p | grep -e "$source_hyprland_window_address" | cut -f 1 -d ' '); do
    printf "%s... " "$hook"
    tmux set-hook -p -u "$hook" && echo_success "ok"
  done
}

hyprctl_wrapper() {
  # print hyprctl args, run hyprctl and capture output, colorize it 
  printf "hyprctl %s... " "$*"
  result="$(command hyprctl "$@")"
  if [ ! "$result" = "ok" ]; then
    echo_error "$result"
  else
    echo_success "$result"
  fi
}

setup-window() {
  echo_important "setting window properties"
  read -r is_pinned is_fullscreen < <(hyprctl clients -j | jq -r ".[] | select(.address == \"$source_hyprland_window_address\") | \"\(.pinned)\t\(.fullscreen)\"")
  
  # Float the source window and move it to the same ws as target
  hyprctl_wrapper dispatch setfloating address:"$source_hyprland_window_address"
  hyprctl_wrapper dispatch movetoworkspace "$target_hyprland_window_ws_id",address:"$source_hyprland_window_address"
  # Unfullscreen window if its fullscreen
  if [ "$is_fullscreen" = "true" ]; then 
    hyprctl_wrapper dispatch fullscreen
  fi
  # Unpin window if its pinned
  if [ "$is_pinned" = "true" ]; then 
    hyprctl_wrapper dispatch pin address:"$source_hyprland_window_address"
  fi
  # Make window unable to focus (TODO: focus it when switching to this window's pane)
  hyprctl_wrapper setprop address:"$source_hyprland_window_address" nofocus 1 lock
  hyprctl_wrapper setprop address:"$source_hyprland_window_address" forcenoborder 1 lock
}

reset-window() {
  echo_important "resetting window properties"
  hyprctl_wrapper setprop address:"$source_hyprland_window_address" nofocus 0
  hyprctl_wrapper setprop address:"$source_hyprland_window_address" forcenoborder 0
}

cleanup() {
  echo_important "cleaning up"
  reset-hooks
  reset-window
  exit
}
trap cleanup SIGINT SIGTERM

setup-window
setup-hooks

echo_important "calling inital hook"
~/.config/scripts/hyprmux/hyprmux-hook.sh "initial" "$target_tmux_pane_id" "$target_tmux_window_id" "$source_hyprland_window_address" "$target_hyprland_window_address" >/dev/null

# hyprland socket listener that will stop the script if either source or target windows are closed
listener() {
  socat - "UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock" | while read -r line; do
    event="${line%%>>*}"
    args="${line#*>>}"

    case "$event" in
      closewindow)
        addr="0x${args}"
        if [ "$addr" = "$target_hyprland_window_address" ]; then
          echo_important "target window closed, exiting"
        elif  [ "$addr" = "$source_hyprland_window_address" ]; then
          echo_important "source window closed, exiting"
        fi
        break
        ;;
      activewindowv2)
        addr="0x${args}"
        if [ ! "$addr" = "$source_hyprland_window_address" ] && [ -n "$args" ]; then
          hyprctl setprop address:"$source_hyprland_window_address" nofocus 1 lock
        fi
        ;;
    esac
  done
}
echo_important "starting hyprland socket listener"
listener

cleanup

