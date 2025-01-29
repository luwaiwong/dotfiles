#! /bin/bash


# Install yay
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si


# Install hyprland essentials
yay -S \
	hyprland
	
#
