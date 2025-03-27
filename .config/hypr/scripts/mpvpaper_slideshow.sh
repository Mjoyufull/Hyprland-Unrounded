#!/bin/bash
# mpvpaper_slideshow.sh – seamless wallpaper transitions with delayed process cleanup
set -euo pipefail

##########################
# Configuration Settings #
##########################
wallpaperDirs=(
    "/home/chris/Pictures/newpc/mikunewgen/"
)
imageExts=("jpg" "jpeg" "png" "bmp" "gif")
videoExts=("mp4" "mkv" "webm" "avi")

# Weights: relative chances. They MUST add up to 100.
videoWeight=60
imageWeight=40

if (( videoWeight + imageWeight != 100 )); then
    echo "ERROR: Weights don't add up to 100. Seriously, this sum gen Z shit." >&2
    exit 1
fi

# Options for separate wallpapers per monitor.
# For images: default separate (1); videos: default same on all monitors (0).
separate_images=1
separate_videos=0

# Video audio options.
# Set videoMute to 1 to mute videos (default), 0 for unmuted.
videoMute=0
# If unmuted, specify volume (1-100); default is 100.
videoVolume=100

# Transition interval in seconds (wallpaper duration)
transitionInterval=240

# Scaling options for centering & filling the screen
scalingOptions="--panscan=1.0 --keepaspect"

historyFile="/tmp/mpvpaper_history"
pidFile="/tmp/mpvpaper_slideshow_pid"
logFile="/tmp/mpvpaper_slideshow.log"

##############################
# Utility and Logging Tools  #
##############################
log_message() {
    msg="$(date '+%Y-%m-%d %H:%M:%S') - $1"
    echo "$msg"
    echo "$msg" >> "$logFile"
}

# Nuke all mpvpaper processes.
nuke_all_mpvpaper() {
    log_message "Nuking ALL mpvpaper instances with killall."
    killall -q mpvpaper || true
    sleep 1
}

# Write our PID to file so trigger scripts can signal us.
echo $$ > "$pidFile"
log_message "Main script PID: $$"
trap 'rm -f "$pidFile"; nuke_all_mpvpaper; exit' EXIT

##########################################
# Detect Connected Outputs (Monitors)    #
##########################################
get_monitors() {
    monitors=()
    if command -v hyprctl >/dev/null 2>&1 && hyprctl -j monitors >/dev/null 2>&1; then
        log_message "Using hyprctl for monitor detection."
        monitors=( $(hyprctl -j monitors | jq -r '.[].name') )
    elif command -v wlr-randr >/dev/null 2>&1; then
        log_message "Using wlr-randr for monitor detection."
        while IFS= read -r line; do
            monitor=$(echo "$line" | awk '{print $1}')
            monitors+=("$monitor")
        done < <(wlr-randr | grep -E '^\S')
    else
        log_message "No supported monitor detection tool found. Install hyprctl (with jq) or wlr-randr."
        exit 1
    fi

    if [[ ${#monitors[@]} -eq 0 ]]; then
        log_message "No monitors found. Fuck off."
        exit 1
    fi
    log_message "Monitors detected: ${monitors[*]}"
}

##########################
# Indexing Wallpaper Files
##########################
index_wallpapers() {
    videoFiles=()
    imageFiles=()
    for dir in "${wallpaperDirs[@]}"; do
        if [[ -d "$dir" ]]; then
            for file in "$dir"/*; do
                [[ -f "$file" ]] || continue
                ext="${file##*.}"
                ext="${ext,,}"
                if [[ " ${imageExts[*]} " =~ " $ext " ]]; then
                    imageFiles+=("$file")
                elif [[ " ${videoExts[*]} " =~ " $ext " ]]; then
                    videoFiles+=("$file")
                else
                    log_message "Discarding unsupported file: $file"
                fi
            done
        else
            log_message "Directory not found: $dir"
        fi
    done
    log_message "Indexed ${#videoFiles[@]} videos and ${#imageFiles[@]} images."
    if [[ ${#videoFiles[@]} -eq 0 && ${#imageFiles[@]} -eq 0 ]]; then
        log_message "No valid wallpaper files found."
        exit 1
    fi
}

#######################################
# Pick a Random Wallpaper Cycle
#######################################
pick_cycle() {
    totalWeight=$(( videoWeight + imageWeight ))
    rand=$(( RANDOM % totalWeight ))
    if [[ $rand -lt $videoWeight ]] && [[ ${#videoFiles[@]} -gt 0 ]]; then
        cycleType="video"
    elif [[ ${#imageFiles[@]} -gt 0 ]]; then
        cycleType="image"
    else
        cycleType="video"
    fi

    cycle=()
    if [[ $cycleType == "image" ]]; then
        if (( separate_images )); then
            for (( i=0; i<${#monitors[@]}; i++ )); do
                idx=$(( RANDOM % ${#imageFiles[@]} ))
                cycle+=("${imageFiles[$idx]}")
            done
        else
            idx=$(( RANDOM % ${#imageFiles[@]} ))
            for (( i=0; i<${#monitors[@]}; i++ )); do
                cycle+=("${imageFiles[$idx]}")
            done
        fi
    else
        if (( separate_videos )); then
            for (( i=0; i<${#monitors[@]}; i++ )); do
                idx=$(( RANDOM % ${#videoFiles[@]} ))
                cycle+=("${videoFiles[$idx]}")
            done
        else
            idx=$(( RANDOM % ${#videoFiles[@]} ))
            for (( i=0; i<${#monitors[@]}; i++ )); do
                cycle+=("${videoFiles[$idx]}")
            done
        fi
    fi

    cycleRecord="$cycleType ${cycle[*]}"
    echo "$cycleRecord" >> "$historyFile"
    currentCycle=$(wc -l < "$historyFile")
    log_message "Picked new cycle #$currentCycle of type $cycleType: ${cycle[*]}"
}

#######################################
# Display a Cycle on All Monitors
#######################################
display_cycle() {
    record=$(sed -n "${currentCycle}p" "$historyFile")
    read -r cycleType rest <<< "$record"
    read -r -a wallpapers <<< "$rest"
    log_message "Displaying cycle #$currentCycle ($cycleType) on monitors: ${monitors[*]}"

    # Capture current mpvpaper PIDs before launching new instances
    old_pids=$(pgrep -x mpvpaper || true)
    log_message "Previous mpvpaper PIDs: $old_pids"

    # Launch new mpvpaper instances
    declare -a new_pids
    for i in "${!monitors[@]}"; do
        monitor="${monitors[$i]}"
        wallpaper="${wallpapers[$i]}"
        if [[ $cycleType == "video" ]]; then
            if (( videoMute )); then
                mpv_options="no-audio --loop-playlist ${scalingOptions}"
            else
                mpv_options="--loop-playlist --volume=${videoVolume} ${scalingOptions}"
            fi
            mpvpaper -f -o "$mpv_options" "$monitor" "$wallpaper" &
        else
            mpvpaper -f -n "$transitionInterval" -o "${scalingOptions}" "$monitor" "$wallpaper" &
        fi
        new_pid=$!
        new_pids+=($new_pid)
        log_message "Launched mpvpaper on $monitor with PID $new_pid"
    done

    # Delayed kill of old instances (5-second delay)
    (
        sleep 5  # Let new wallpapers fully render first
        if [ -n "$old_pids" ]; then
            log_message "Delayed termination of old PIDs: $old_pids"
            # Only kill if they're still running
            for pid in $old_pids; do
                if ps -p "$pid" > /dev/null; then
                    kill "$pid" 2>/dev/null && log_message "Killed PID $pid" || true
                fi
            done
        fi
    ) &  # Run in background to avoid blocking
    disown  # Prevent zombie processes if script exits

    log_message "Scheduled old instance termination in 5 seconds"
}

#######################################
# History Navigation: Next and Previous
#######################################
next_cycle() {
    totalCycles=$(wc -l < "$historyFile")
    if (( currentCycle >= totalCycles )); then
        pick_cycle
    else
        currentCycle=$(( currentCycle + 1 ))
        log_message "Moving forward to cycle #$currentCycle"
    fi
    display_cycle
}

previous_cycle() {
    if (( currentCycle > 1 )); then
        currentCycle=$(( currentCycle - 1 ))
        log_message "Moving backward to cycle #$currentCycle"
        display_cycle
    else
        log_message "Already at the first cycle; cannot go back."
    fi
}

##########################
# Signal Trapping for Controls
##########################
trap 'log_message "SIGUSR1 caught - triggering next cycle"; next_cycle' SIGUSR1
trap 'log_message "SIGUSR2 caught - triggering previous cycle"; previous_cycle' SIGUSR2

##########################
# Custom Sleep That Reacts to Signals
##########################
sleep_with_signals() {
    local remaining=$1
    while (( remaining > 0 )); do
        sleep 1 || true
        (( remaining-- ))
    done
}

##########################
# Main Execution Flow
##########################
get_monitors
index_wallpapers
> "$historyFile"
pick_cycle
display_cycle

while true; do
    log_message "Sleeping for $transitionInterval seconds before next cycle..."
    sleep_with_signals "$transitionInterval"
    next_cycle
done
