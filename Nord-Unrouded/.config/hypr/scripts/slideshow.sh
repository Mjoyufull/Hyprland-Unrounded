#!/bin/bash

# Set the paths to both directories
wallpapersDir1="$HOME/Pictures/newpc/miku/Norded/Twitter"
wallpapersDir2="$HOME/Pictures/newpc/miku/Norded/"

# Combine both directories into one array
allWallpapers=("${wallpapersDir1}"/* "${wallpapersDir2}"/*)

# Function to change the wallpaper
change_wallpaper() {
    # Check if the wallpapers array is empty
    if [ ${#allWallpapers[@]} -eq 0 ]; then
        # Refill the array if empty
        allWallpapers=("${wallpapersDir1}"/* "${wallpapersDir2}"/*)
    fi

    # Select a random wallpaper from the array
    wallpaperIndex=$(( RANDOM % ${#allWallpapers[@]} ))
    selectedWallpaper="${allWallpapers[$wallpaperIndex]}"

    # Apply the wallpaper
    swww img --resize fit --fill-color "#2e3440" --transition-type grow --transition-pos 0.854,0.977 --transition-step 90 "$selectedWallpaper"

 
}

# Function to handle the skip signal
skip_wallpaper() {
    pkill -USR1 -f "$0"
}

# Trap the USR1 signal to skip the wallpaper
trap skip_wallpaper SIGUSR1

# Infinite loop to change wallpaper every 5 minutes
while true; do
    change_wallpaper
    sleep 4m &
    wait $!
done

