#!/bin/sh

if [ -z "$XDG_RUNTIME_DIR" ]; then
    echo "XDG_RUNTIME_DIR is not set"
    exit 1
fi

server_socket="${XDG_RUNTIME_DIR}/foot-popup-server.sock"
if [ ! -S "$server_socket" ]; then
    echo "$server_socket is not a socket"
    exit 1
fi

# make sure there's only 1 popup at the same time
lockfile="${XDG_RUNTIME_DIR}/foot-popup.lock"
flock -n "$lockfile" \
    footclient \
    --server-socket "$server_socket" \
    --override colors.background=3D484D \
    --override colors.sixel0=3D484D \
    --app-id foot-popup \
    --window-size-chars 80x24 \
    "$@"

