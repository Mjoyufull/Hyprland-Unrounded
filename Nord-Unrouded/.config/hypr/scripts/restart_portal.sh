#!/bin/bash
systemctl --user stop pipewire pipewire-pulse wireplumber xdg-desktop-portal xdg-desktop-portal-hyprland
sleep 2
systemctl --user start pipewire pipewire-pulse wireplumber
sleep 2
systemctl --user start xdg-desktop-portal xdg-desktop-portal-hyprland