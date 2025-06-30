#! /bin/bash

# list of apps to update
list = (
    cava
    hypr
    kitty
    omposh
    rofi
    spicetify
    waybar
    wlogout
)

# Delete existing config files in dotfiles directory
for dir in $list; do
    rm -rf ./$dir
done

# Copy config files to ~/.config

for dir in $list; do
    cp -r ~/.config/$dir ./
done

