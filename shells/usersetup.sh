#!/bin/bash

source ~/tools/dotfiles/utils/expcolors.sh

# Uninstalling packages
uninstallPackages() {
  section "Uninstalling packages"

  # Remove packages
  sudo apt remove vim nano nodejs --purge -y

  # Remove snaps
  sudo snap remove autopsy 2>/dev/null
  
  sudo apt autoremove -y

  sudo gunzip /usr/share/wordlists/rockyou.txt.gz 2>/dev/null
}

# Cloning dotfiles
cloneDotfiles() {
  section "Cloning dotfiles"

  mkdir -p ~/tools

  cd ~/tools

  # Clone dotfiles (if it already exists, update it)
  if [ -d ~/tools/dotfiles ]; then
    cd ~/tools/dotfiles
    git pull
  else
    git clone https://github.com/Yoswell/dotfiles.git ~/tools/dotfiles
  fi
}

# Setting up wallpapers
setupWallpapers() {
  section "Setting up wallpapers"

  cd ~/tools/dotfiles

  # Copy wallpapers from dotfiles
  cp -rf wallpapers ~/Desktop/

  # Set wallpapers (verify if directories exist)
  sudo cp -f wallpapers/xcyberpunk.jpg /usr/share/backgrounds/kali/kali-cubes-16x9.jpg
  sudo cp -f wallpapers/xcyberpunk.jpg /usr/share/backgrounds/kali/kali-cubes2-16x9.jpg
  sudo cp -f wallpapers/xcyberpunk.jpg /usr/share/backgrounds/kali/login.svg
}

# Creating directories
createDirectories() {
  section "Creating directories"

  cd ~/Documents
  mkdir -p htbdemy htbapp htbchall ecsc
}

# Setting up BIN and ZSH
setupBinAndZsh() {
  section "Setting up BIN and ZSH"

  # Oh My Zsh
  rm -rf ~/.oh-my-zsh
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

  # Create bin directory if it doesn't exist
  mkdir -p ~/bin
  mkdir -p ~/.oh-my-zsh/custom/plugins

  cd ~/tools/dotfiles

  # ZSH and BIN of normal user
  cp -rf zshrc ~/.zshrc
  cp -rf bin ~/ && chmod +x ~/bin/* 2>/dev/null

  # ZSH plugins (clean before cloning)
  rm -rf ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
  rm -rf ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
  rm -rf ~/.oh-my-zsh/custom/plugins/zsh_tshark_autocomplete

  git clone https://github.com/zsh-users/zsh-autosuggestions.git ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
  git clone https://github.com/Yoswell/zsh_tshark_autocomplete.git ~/.oh-my-zsh/custom/plugins/zsh_tshark_autocomplete

  # Powerlevel10k
  rm -rf ~/.oh-my-zsh/custom/themes/powerlevel10k
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/.oh-my-zsh/custom/themes/powerlevel10k

  # Configure theme in .zshrc
  sed -i 's|ZSH_THEME=.*|ZSH_THEME="powerlevel10k/powerlevel10k"|' ~/.zshrc
}

# Setting up user themes
setupUserThemes() {
  section "Setting up user themes"

  cd ~/

  # Create necessary directories
  mkdir -p .themes
  mkdir -p .config/micro/colorschemes
  mkdir -p .config/kitty
  mkdir -p .config/polybar
  mkdir -p .config/xfce4/xfconf/xfce-perchannel-xml
  mkdir -p .config/gtk-3.0

  cd ~/tools/dotfiles/config

  # Extract themes from themes directory
  tar -xf themes/MANTI.tar -C ~/.themes/
  tar -xf themes/SUN.tar -C ~/.themes/

  # Copy schemes from schemes directory
  cp -f schemes/micro_theme.micro ~/.config/micro/colorschemes/
  cp -f schemes/kitty.conf ~/.config/kitty/
  cp -f schemes/tmux.conf ~/.tmux.conf

  # Copy polybar configuration
  if [ -f polybar/config.ini ]; then
    cp -f polybar/config.ini ~/.config/polybar/
    cp -rf polybar/scripts ~/.config/polybar/
    chmod +x ~/.config/polybar/scripts/*.sh 2>/dev/null
  fi

  # Copy rofi theme system wide
  sudo cp -f schemes/rofi_theme.rasi /usr/share/rofi/themes/

  # Update XFCE configs (located at the root of dotfiles)
  cd ~/tools/dotfiles
  if [ -d xfce ]; then
    cp -f xfce/xfce4-keyboard-shortcuts.xml ~/.config/xfce4/xfconf/xfce-perchannel-xml/ 2>/dev/null
    cp -f xfce/xfce4-power-manager.xml ~/.config/xfce4/xfconf/xfce-perchannel-xml/ 2>/dev/null
    cp -f xfce/xfce4Settings.xml ~/.config/xfce4/xfconf/xfce-perchannel-xml/ 2>/dev/null
    cp -f xfce/xfce4-desktop.xml ~/.config/xfce4/xfconf/xfce-perchannel-xml/ 2>/dev/null
    cp -f xfce/thunar.xml ~/.config/xfce4/xfconf/xfce-perchannel-xml/ 2>/dev/null
  fi
}

# Installing valuable fonts
installFonts() {
  section "Installing fonts"

  cd ~/tools/dotfiles/config/fonts

  # Create font directories
  sudo mkdir -p /usr/share/fonts/truetype/jetbrains-mono
  sudo mkdir -p /usr/share/fonts/truetype/proto-nerd

  # Install fonts
  sudo unzip -o JET.zip -d /usr/share/fonts/truetype/jetbrains-mono
  sudo unzip -o PROTO.zip -d /usr/share/fonts/truetype/proto-nerd

  sudo fc-cache -f -v
}

main() {
  if [ "$EUID" -eq 0 ]; then
    warning "Do not run as root ~ use setup-root.sh for root configurations"
    exit 1
  fi

  section "Starting Complete Setup (USER PART)"
  info "This script will install USER configurations without asking"
  warning "Press Enter to continue or Ctrl+C to cancel..."
  read -r

  # Installation sequence
  uninstallPackages
  cloneDotfiles
  setupWallpapers
  createDirectories
  setupBinAndZsh
  setupUserThemes
  installFonts

  # Completion message
  success "All user configurations applied"
  info "Run: source ~/.zshrc"
  info "Then run: sudo ./rootsetup.sh"
}

# Execute main function
main "$@"