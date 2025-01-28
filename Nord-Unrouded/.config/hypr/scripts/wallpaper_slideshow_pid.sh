#!/bin/bash

# Write the PID of the script to a file for later retrieval
echo $$ > /tmp/wallpaper_slideshow_pid

# Clean up the PID file on exit
trap 'rm -f /tmp/wallpaper_slideshow_pid' EXIT

# Set the paths to all wallpaper directories with weights
declare -A weightedDirs=(
    ["$HOME/Pictures/newpc/mikunewgennorded"]=40    # 40% chance
    ["$HOME/Pictures/newpc/miku/Norded"]=20         # 20% chance
    ["$HOME/Pictures/newpc/miku/Norded/Twitter"]=10  # 10% chance
    ["$HOME/Pictures/newpc/miku/cyberpunk nordic"]=10
    ["$HOME/Pictures/newpc/miku/explore nord"]=10
    ["$HOME/Pictures/newpc/miku/vtuber nord"]=10
)

# Files to store wallpaper history and counters
HISTORY_FILE="/tmp/wallpaper_history"
CURRENT_INDEX_FILE="/tmp/wallpaper_current_index"
COUNTER_FILE="/tmp/wallpaper_counter"
CYCLE_LENGTH=15      # Length of cycle before checking for repeat
REPEAT_CHANCE=63     # 63% chance to show a repeat at cycle end
MAX_HISTORY=50      # Maximum history size

# Initialize files if they don't exist
touch "$HISTORY_FILE"
echo "0" > "$COUNTER_FILE"
echo "-1" > "$CURRENT_INDEX_FILE"  # Start at -1 since first wallpaper will increment to 0

# Log function with timestamps
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> /tmp/wallpaper_slideshow.log
}

# Function to get current index
get_current_index() {
    cat "$CURRENT_INDEX_FILE"
}

# Function to set current index
set_current_index() {
    echo "$1" > "$CURRENT_INDEX_FILE"
}

# Function to get all wallpapers from a directory
get_wallpapers() {
    local dir="$1"
    if [ -d "$dir" ]; then
        find "$dir" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \)
    fi
}

# Function to select a directory based on weights
select_weighted_directory() {
    local roll=$(( RANDOM % 100 ))
    local cumulative=0
    
    for dir in "${!weightedDirs[@]}"; do
        cumulative=$((cumulative + weightedDirs[$dir]))
        if [ $roll -lt $cumulative ]; then
            echo "$dir"
            return
        fi
    done
    
    echo "${!weightedDirs[0]}"
}

# Function to check if we're at a cycle end and should try a repeat
check_cycle_repeat() {
    local counter=$(cat "$COUNTER_FILE")
    
    if [ $((counter % CYCLE_LENGTH)) -eq 0 ] && [ $counter -ne 0 ]; then
        local roll=$(( RANDOM % 100 ))
        if [ $roll -lt $REPEAT_CHANCE ]; then
            return 0  # Should show repeat
        fi
    fi
    return 1  # Should not show repeat
}

# Function to select a random wallpaper from previous cycle
select_repeat_wallpaper() {
    local history_size=$(wc -l < "$HISTORY_FILE")
    local start_line=$((history_size - CYCLE_LENGTH))
    if [ $start_line -lt 0 ]; then
        start_line=0
    fi
    
    local cycle_wallpapers=($(tail -n "$CYCLE_LENGTH" "$HISTORY_FILE"))
    local selected=${cycle_wallpapers[$RANDOM % ${#cycle_wallpapers[@]}]}
    
    if [ -f "$selected" ]; then
        echo "$selected"
        return 0
    fi
    return 1
}

# Function to increment the wallpaper counter
increment_counter() {
    local counter=$(cat "$COUNTER_FILE")
    echo $((counter + 1)) > "$COUNTER_FILE"
}

# Function to select a wallpaper
select_wallpaper() {
    if check_cycle_repeat; then
        log_message "End of cycle, attempting to show a repeat wallpaper"
        local repeat_wallpaper=$(select_repeat_wallpaper)
        
        if [ -n "$repeat_wallpaper" ]; then
            log_message "Selected repeat wallpaper: $repeat_wallpaper"
            echo "$repeat_wallpaper"
            echo "$repeat_wallpaper" >> "$HISTORY_FILE"
            increment_counter
            return
        fi
        log_message "Failed to select repeat wallpaper, falling back to new selection"
    fi
    
    local selected_dir=$(select_weighted_directory)
    local wallpapers=($(get_wallpapers "$selected_dir"))
    local recent_wallpapers=($(tail -n "$CYCLE_LENGTH" "$HISTORY_FILE"))
    
    if [ ${#wallpapers[@]} -eq 0 ]; then
        log_message "No wallpapers found in $selected_dir, trying another directory"
        select_wallpaper
        return
    fi
    
    local attempts=0
    local max_attempts=20
    while [ $attempts -lt $max_attempts ]; do
        local selected=${wallpapers[$RANDOM % ${#wallpapers[@]}]}
        
        local is_recent=0
        for recent in "${recent_wallpapers[@]}"; do
            if [ "$selected" = "$recent" ]; then
                is_recent=1
                break
            fi
        done
        
        if [ $is_recent -eq 0 ]; then
            echo "$selected"
            echo "$selected" >> "$HISTORY_FILE"
            increment_counter
            
            if [ $(wc -l < "$HISTORY_FILE") -gt $MAX_HISTORY ]; then
                sed -i '1d' "$HISTORY_FILE"
            fi
            return
        fi
        
        attempts=$((attempts + 1))
    done
    
    local selected=${wallpapers[$RANDOM % ${#wallpapers[@]}]}
    echo "$selected"
    echo "$selected" >> "$HISTORY_FILE"
    increment_counter
}

# Function to apply wallpaper
apply_wallpaper() {
    local wallpaper="$1"
    local index="$2"
    
    log_message "Applying wallpaper: $wallpaper (index: $index)"
    
    swww img --fill-color 3b4252 \
             --resize crop \
             -f CatmullRom \
             --transition-type grow \
             --transition-pos 0.854,0.977 \
             --transition-step 90 \
             --transition-fps 60 \
             "$wallpaper"
             
    set_current_index "$index"
}

# Function to change the wallpaper
change_wallpaper() {
    local selectedWallpaper=$(select_wallpaper)
    local newIndex=$(($(get_current_index) + 1))
    apply_wallpaper "$selectedWallpaper" "$newIndex"
}

# Function to handle next wallpaper request
next_wallpaper() {
    log_message "Next wallpaper requested"
    local currentIndex=$(get_current_index)
    local totalWallpapers=$(wc -l < "$HISTORY_FILE")
    
    if [ $((currentIndex + 1)) -lt $totalWallpapers ]; then
        # There's a next wallpaper in history
        local nextWallpaper=$(sed -n "$((currentIndex + 2))p" "$HISTORY_FILE")
        if [ -f "$nextWallpaper" ]; then
            apply_wallpaper "$nextWallpaper" $((currentIndex + 1))
            return
        fi
    fi
    
    # If we get here, we need a new wallpaper
    change_wallpaper
}

# Function to handle previous wallpaper request
prev_wallpaper() {
    log_message "Previous wallpaper requested"
    local currentIndex=$(get_current_index)
    
    if [ $currentIndex -gt 0 ]; then
        local prevWallpaper=$(sed -n "${currentIndex}p" "$HISTORY_FILE")
        if [ -f "$prevWallpaper" ]; then
            apply_wallpaper "$prevWallpaper" $((currentIndex - 1))
            return
        fi
    fi
    
    log_message "No previous wallpaper available"
}

# Trap signals for next and previous wallpaper actions
trap 'next_wallpaper' SIGUSR1
trap 'prev_wallpaper' SIGUSR2

# Start with initial wallpaper
log_message "Starting wallpaper slideshow"
change_wallpaper

# Main loop
while true; do
    log_message "Sleeping for 4 minutes before the next wallpaper change"
    sleep 240 & 
    wait $!
    
    if [ $? -eq 0 ]; then
        change_wallpaper
    fi
done