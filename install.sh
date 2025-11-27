#! /bin/bash

# Install yay if not already installed
if ! pacman -Q yay &> /dev/null; then
    log 'Yay not installed. Installing...'

    # Install
    sudo pacman -S --needed git base-devel $noconfirm
    cd /tmp
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si
    cd ..
    rm -rf yay

    # Setup
    yay -Y --gendb
    yay -Y --devel --save
fi


read -p "Do you want to install packages? [y/N]: " install_packages

if [[ "$install_packages" =~ ^[Yy]$ ]]; then
    # Add the nvidia source line just after the monitor config line
    yay -S cava hyprland kitty ghostty rofi waybar-cava wlogout hyprsome fish mako betterdiscordctl--noconfirm
fi


# Copy config files to ~/.config
for dir in cava hypr kitty ghostty rofi spicetify quickshell wlogout fish mako waybar; do
    cp -r ./$dir ~/.config
done

cp ./.bashrc ~/
cp ./.profile ~/
cp -r ./wallpapers ~/pictures/
cp -r ./wallpapers+ ~/pictures/

# Ask for monitor configuration
hyprconf="$HOME/.config/hypr/hyprland.conf"
if [[ ! -f "$hyprconf" ]]; then
    echo "Hyprland configuration file not found at $hyprconf"
    exit 1
fi

echo "Pick hardware setup"
echo "You may have to change monitor settings manually in ~/.config/hypr/hardware/"
select hardware_conf in "dualmonitor.conf" "singlehighres.conf"; do
    if [[ -n "$hardware_conf" ]]; then
        break
    else
        echo "pick"
    fi
done

# Add the correct source line at the bottom of hyprland.conf
echo  "source = \$hardware/$hardware_conf" >> "$hyprconf"

# Ask for nvidia configuration
# Ask user if they want to include nvidia.conf
read -p "Do you want to include NVIDIA config (nvidia.conf)? [y/N]: " include_nvidia

# Remove any previous source line for nvidia.conf
sed -i '/source = .*\/hardware\/nvidia\.conf/d' "$hyprconf"

if [[ "$include_nvidia" =~ ^[Yy]$ ]]; then
    # Add the nvidia source line just after the monitor config line
    echo  "source = \$hardware/nvidia.conf" >> "$hyprconf"
fi

echo  "all done :)"
