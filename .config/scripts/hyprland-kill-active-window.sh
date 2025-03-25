#!/bin/sh

tab='	'
IFS="$tab"

result="$(hyprctl activewindow -j | jq -r '{ a: .address, b: .pid, c: .initialClass } | join("\t")')"
set -- $result
addr="$1"
pid="$2"
initial_class="$3"

hyprctl dispatch closewindow address:"$addr"

# prevent killing foot server
case "$initial_class" in
*foot*)
    exit;;
esac

sleep 3

# if process has no windows opened but is still alive after 3 seconds, kill it
if hyprctl clients -j | \
    jq -er --arg pid "$pid" '[.[] | select(.pid == ($pid | tonumber))] | length < 1';
then
    kill -TERM "$pid"
fi

