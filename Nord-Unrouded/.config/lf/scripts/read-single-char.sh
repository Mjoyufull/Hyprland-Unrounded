#!/bin/sh

read_single_char() {
    stty_settings=$(stty -g)
    stty raw -echo
    dd if=/dev/tty bs=1 count=1 2>/dev/null
    stty "$stty_settings"
}
direction=$(read_single_char)

printf $direction

