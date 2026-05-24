#!/bin/bash

# Automatic script to clean .config
# Save as: ~/.local/bin/clean_config_auto.sh

CONFIG_DIR="$HOME/.config"

# List of items to keep
KEEP_ITEMS=(
  "micro" "powershell" "rofi" "Vector 35"
  "dconf" "Mousepad" "pulse" "Thunar" "Windsurf"
  "gtk-3.0" "nautilus" "qt6ct" "user-dirs.dirs" "user-dirs.locale"
  "xfce4" "kitty" "qterminal.org" "wireshark" "Caido" "obsidian" "Windsurf" "polybar"
)

clean_config_auto() {
  echo "Cleaning $CONFIG_DIR..."

  # Iterate through all items in .config
  for item in "$CONFIG_DIR"/*; do
    if [ -e "$item" ]; then
      item_name=$(basename "$item")
      delete=true

      # Check if item is in the keep list
      for keep_item in "${KEEP_ITEMS[@]}"; do
        if [[ "$item_name" == "$keep_item" ]]; then
          delete=false
          break
        fi
      done

      # Delete if not in keep list
      if $delete; then
        echo "Deleting: $item_name"
        rm -rf "$item"
      fi
    fi
  done

  echo "Cleanup completed"
}

# Execute the function
clean_config_auto
