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

yay -S cava hyprland kitty omposh rofi waybar-cava wlogout --noconfirm

# Copy config files to ~/.config
for dir in cava hypr kitty omposh rofi spicetify waybar wlogout; do
    cp -r ./$dir ~/.config
done

cp ./.bashrc ~/
cp ./.profile ~/

# Ask for monitor configuration
hyprconf="$HOME/.config/hypr/hyprland.conf"
if [[ ! -f "$hyprconf" ]]; then
    echo "Hyprland configuration file not found at $hyprconf"
    exit 1
fi

echo "Choose a monitor config?"
echo "You may have to change monitor settings manually in ~/.config/hypr/hardware/dualmonitor.conf"
select monitor_conf in "dualmonitor.conf" "singlemonitor.conf"; do
    if [[ -n "$monitor_conf" ]]; then
        break
    else
        echo "1 screen or 2 screens."
    fi
done
yay -S hyprsome --noconfirm

# Add the correct source line at the top of hyprland.conf
echo  "\nsource = \$hardware/$monitor_conf" >> "$hyprconf"

# Ask for nvidia configuration
# Ask user if they want to include nvidia.conf
read -p "Do you want to include NVIDIA config (nvidia.conf)? [y/N]: " include_nvidia

# Remove any previous source line for nvidia.conf 
sed -i '/source = .*\/hardware\/nvidia\.conf/d' "$hyprconf"

if [[ "$include_nvidia" =~ ^[Yy]$ ]]; then
    # Add the nvidia source line just after the monitor config line
    echo  "\nsource = \$hardware/nvidia.conf" >> "$hyprconf"    
fi

echo  "all done :)"    

