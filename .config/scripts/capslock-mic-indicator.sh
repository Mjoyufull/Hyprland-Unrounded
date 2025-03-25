#!/usr/bin/env bash

# Paths to capslock LEDs are not consistent
led_paths=$(find /sys/class/leds/ -name 'input*::capslock' | while read line; do echo $line/brightness; done)
echo "Found capslock leds:"
echo $led_paths

led_on() {
	echo 1 | tee $led_paths > /dev/null
}

led_off() {
	echo 0 | tee $led_paths > /dev/null
}

# Idk if this is necessary but we'll explicitly kill all jobs so no orphans are left
# Also turning the led off so it doesn't stay permanently on
cleanup() {
	kill $(jobs -p)
	led_off
	exit
}
trap cleanup HUP INT QUIT TERM EXIT ERR

# Initial check
default_source=$(pactl get-default-source)
is_muted=$(pactl get-source-mute "$default_source")
echo $is_muted
if [ "$is_muted" == "Mute: no" ]; then
	led_on;
else
	led_off;
fi;

# Infinite loop that turns led off if nothing is using the microphone for 5s
check_for_no_listeners() {
	while :
	do
		if [ ! "$(pactl list source-outputs)" ]; then led_off; fi
		sleep 10
	done
}
check_for_no_listeners&

# Listen for pulseaudio events
pactl subscribe 2> /dev/null | while read n event n type id; do
	if [ "$event" = "'change'" -a "$type" = "source" ]; then
		default_source=$(pactl get-default-source)
		is_muted=$(pactl get-source-mute "$default_source")
		if [ "$is_muted" = "Mute: no" ]; then
			led_on;
		else
			led_off;
		fi;
	fi;
done

