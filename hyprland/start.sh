# initialize wallpaper daemon
swww init &
# set wallpaper
swww img ~/Downloads/nix-wallpaper-dracula.png &

# networking
nm-applet --indicator &

waybar &
dunst
