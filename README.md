# Hyprland-Unrounded

![Screenshot_20250128-015926](https://github.com/user-attachments/assets/73008c54-f2a9-4424-ba23-98f442c3b2b7)


---


## Overview

This repository contains the configuration files I used to customize my Hyprland setup. The primary focus is on creating a cohesive look with a Nord color scheme applied across various tools and applications. Below, you'll find a list of the configuration directories and files, as well as instructions on how to set up everything to achieve the same look.

## Directories and Configurations

Here’s a quick overview of the directories and tools used in this setup:

- **Kvantum**: For Qt theme customization.
- **Thunar**: File manager with custom configurations.
- **ags**
- **bat**: A cat clone with syntax highlighting.
- **btop**: A resource monitor that fits the Nord theme.
- **cava**: Music visualizer configured to use the Nord color scheme.
- **dunst**: Custom notification daemon configuration, also Nord-themed.
- **fastfetch**: For system info in the terminal, configured to match the overall theme.
- **gtk-3.0**: GTK3 configurations, applying the Nord theme to GTK3 apps.
- **gtk-4.0**: GTK4 configurations, applying the Nord theme to GTK4 apps.
- **hypr**: Core Hyprland configuration files.
- **kitty**: Terminal emulator configured with a Nord theme and custom Zsh settings.
- **neofetch**: Displays system information with a custom configuration.
- **palletes/rofi**: Custom color palettes for Rofi to match the Nord theme.
- **qalculate**: Custom configurations for the calculator app.
- **qt6ct**: Configuration for Qt6 apps to ensure they follow the Nord theme.
- **rofi**: Rofi application launcher with custom themes and settings.
- **Hyprpanel**: Custom status bar configuration, integrating workspace indicators, system info, and more.
- **wlogout**: Logout menu configuration, also themed to fit the overall look.

## Installation and Setup

### Step 1: Install Hyprland
Ensure you have Hyprland installed on your system. Follow the instructions on the [official Hyprland GitHub page](https://github.com/hyprwm/Hyprland) to get started.

### Step 2: Clone This Repository
Clone this repository to your system:
```bash
git clone https://github.com/Mjoyufull/Hyprland-Unrounded
```
Copy the relevant configuration files to your home directory, usually `~/.config/`.

### Step 3: Install Required Applications

Make sure you have the following applications installed, as needed:

- **Kvantum**: For Qt theming.
- **Thunar**: File manager.
- **ags**: (Install separately as needed).
- **bat**: For syntax-highlighted cat functionality.
- **btop**: A resource monitor.
- **cava**: Music visualizer.
- **dunst**: Notification daemon.
- **fastfetch**: System information fetcher.
- **kitty**: Terminal emulator.
- **neofetch**: System information display.
- **qalculate**: Calculator app.
- **qt6ct**: Qt6 Configuration Tool.
- **rofi**: Application launcher.
- **Hyprpanel**: top bar panel.
- **wlogout**: Logout menu.

### Step 4: Apply the Nord Theme

- **GTK**: Apply the Nord GTK theme which is the NovaOS theme for both GTK3 and GTK4 applications, found in the gtkthemes dir
- **hyprpanel**: hyprpanel config, Customize hyprpanel to match the Nord theme. My configuration includes workspace indicators, a timer, Wi-Fi, Bluetooth, mic, and audio level indicators.
- **Rofi**: Use the custom palette and theme included in the `rofi` and `palletes/rofi` directories.
- **Kitty**: Configure Kitty terminal with the Nord theme and apply Zsh settings that generate pixel art of Pokémon on launch.

### Step 5: Custom Scripts and Keybinds

- **Wallpaper Slideshow**: A custom script using `swww-deamon` cycles through a directory of images,(check config/hypr/scripts) applying the Nord color scheme.
- **Nord wallpapers** : my [repo](https://github.com/Mjoyufull/Nord-wallpapers) for nord themed walls this config uses the norded folders look into the script for more info
- **Screenshot Script**: A custom script using Hyprpicker allows drawing an arrow on screenshots, opening them in an image editor automatically check .
- **hyprpanel Notifications**: hyprpanel has a wallpaper daemon builtin with a Nord theme. Screenshots trigger a custom notification, and there's a bind to open recent notifications.
- **Auto-Tiling and Custom Binds**: I’ve set up keybinds for automatic tiling of applications like Discord, Brave Browser, and Steam in specific workstations.

### Step 6: Fonts

I use **JetBrains Mono** font across all applications. A custom CSS script applies this font in Discord, alongside the Nord theme.

`  // Font
  --font-primary: "JetBrainsMono Nerd Font", monospace;
  ` 

i also use this theme combo in vencord

` https://raw.githubusercontent.com/Overimagine1/old-discord-font/main/dist/old-discord-font.theme.css
https://raw.githubusercontent.com/mr-miner1/Better-Badges/main/BetterBadges(BD).theme.css
https://raw.githubusercontent.com/NYRI4/Discolored/master/support/discolored.theme.css
https://raw.githubusercontent.com/DiscordStyles/HorizontalServerList/master/bd-scss.config.js
https://raw.githubusercontent.com/orblazer/discord-nordic/master/nordic.vencord.css
https://raw.githubusercontent.com/DiscordStyles/HorizontalServerList/deploy/HorizontalServerList.theme.css
` 

### Step 7: Import hyprland config

open Hyprland settings with ` ags -t settings-dialog `  and in general click import and import https://github.com/Mjoyufull/Hyprland-Hyprpanel-nord/blob/main/config/hyprpanel_config.json
into hyprpanel.

## Troubleshooting and Tips

- **Cava Issues**: Ensure `sudo modprobe snd_aloop` is run if you experience issues with Cava not syncing with your audio.
- **Rofi Config**: If the Rofi theme doesn't apply correctly, double-check the `palletes/rofi` directory and ensure it’s correctly referenced in your config files.

## Conclusion

This setup is tailored for a seamless and visually cohesive experience using Hyprland with the Nord theme. Feel free to modify and adapt it to your own needs. If you have any issues or questions, don't hesitate to reach out!

Enjoy your custom Linux experience! 🎉

---
