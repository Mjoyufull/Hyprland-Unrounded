#!/bin/sh

r="${1:-255}"
g="${2:-255}"
b="${3:-255}"

printf '0 0 %d %d %d 0' "$r" "$g" "$b" >'/sys/class/leds/asus::kbd_backlight/kbd_rgb_mode'
printf '1 0 %d %d %d 0' "$r" "$g" "$b" >'/sys/class/leds/asus::kbd_backlight/kbd_rgb_mode'

