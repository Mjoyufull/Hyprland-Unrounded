#!/bin/sh

echo "This will overwrite following files and directories:"
echo "~/.local/share/applications/"
echo "~/bin"
echo
printf "All data in them will be lost! Continue? [y/N] "
read -r answer

if [ ! "$answer" = "y" ]; then
  echo "Abort"
  exit 1
fi

cd ~

if [ ! -d ~/.config/bin ]; then
  echo "~/.config/bin doesn't exist, what have you done? clone the repo properly"
  exit 1
fi
rm -rfv ~/bin
ln -sv .config/bin ~/bin

if [ ! -d ~/.config/applications/ ]; then
  echo "~/.config/applications/ not found, fix your repo bruh"
  exit 1
fi
rm -rfv ~/.local/share/applications
if [ ! -d ~/.local/share ]; then
  mkdir -pv ~/.local/share/
fi
ln -sv ~/.config/applications ~/.local/share/applications

echo "Done"
echo "Make sure to put this in /etc/zsh/zshenv or whatever:"
echo '    export ZDOTDIR="$HOME/.config/zsh/"'

