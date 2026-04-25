#!/bin/bash

# Colors
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'
CYAN='\033[0;36m'
GREEN='\033[0;32m'

# Log functions
success() {
    echo -e "${GREEN}[✓]${NC} :: $1" 
}

error() {
    echo -e "${RED}[✗]${NC} :: $1" 
}

section() {
    echo -e "${CYAN}[ $1 ]${NC}" 
}

info() { 
    echo -e "${BLUE}[i]${NC} :: $1" 
}

warning() {
    echo -e "${YELLOW}[!]${NC} :: $1" 
}

# Uninstalling packages
uninstallPackages() {
    section "Uninstalling packages"
    
    # Remove packages
    sudo apt remove vim nano --purge -y
    sudo apt autoremove -y
    
    # Remove snaps
    sudo snap remove autopsy 2>/dev/null
}

# Cloning dotfiles
cloneDotfiles() {
    section "Cloning dotfiles"

    mkdir -p ~/tools

    cd ~/tools

    # Clone dotfiles
    git clone https://github.com/Yoswell/dotfiles.git ~/tools/dotfiles
}

# Setting up wallpapers
setupWallpapers() {
    section "Setting up wallpapers"

    cd ~/tools/dotfiles

    # Copy wallpapers from dotfiles
    cp -rf wallpapers ~/Desktop/
    
    # Set wallpapers
    sudo cp -f wallpapers/xcyberpunk.png /usr/share/backgrounds/kali/kali-maze-16x9.jpg
    sudo cp -f wallpapers/xcyberpunk.png /usr/share/backgrounds/kali/login.svg
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
    rm -rf powerlevel10k
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    
    # Create bin directory if it doesn't exist
    mkdir -p ~/bin
    mkdir -p ~/.oh-my-zsh/custom/plugins
    
    cd ~/tools/dotfiles

    # ZSH and BIN of normal user
    cp -rf zshrc ~/.zshrc
    cp -rf bin ~/ && chmod +x ~/bin/*
    
    # ZSH plugins
    git clone https://github.com/zsh-users/zsh-autosuggestions.git ~/.oh-my-zsh/custom/plugins
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins
    git clone https://github.com/Yoswell/zsh_tshark_autocomplete.git ~/.oh-my-zsh/custom/plugins
    
    # Powerlevel10k
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/.oh-my-zsh
    
    # ZSH and BIN of root user (NOT HERE - moved to setup-root.sh)
    # sudo cp -f zshrc /root/.zshrc  # <-- MOVED TO ROOT SCRIPT
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
    
    cd ~/tools/dotfiles
    
    # Extract themes from themes directory
    tar -xf themes/mantinight.tar -C ~/.themes/
    tar -xf themes/darksun.tar -C ~/.themes/
    
    # Copy schemes from schemes directory
    cp -f schemes/micro_theme.micro ~/.config/micro/colorschemes/
    cp -f schemes/kitty.conf ~/.config/kitty/
    cp -f schemes/tmux.conf ~/.tmux.conf
    
    # Copy polybar configuration
    cp -f polybar/config.ini ~/.config/polybar/
    cp -rf polybar/scripts ~/.config/polybar/
    chmod +x ~/.config/polybar/scripts/*.sh

    # Copy rofi theme system wide
    sudo cp -f schemes/rofi_theme.rasi /usr/share/rofi/themes/
    
    # Update XFCE configs
    cp -f xfce/xfce4-keyboard-shortcuts.xml ~/.config/xfce4/xfconf/xfce-perchannel-xml/
    cp -f xfce/xfce4-power-manager.xml ~/.config/xfce4/xfconf/xfce-perchannel-xml/
    cp -f xfce/xfce4Settings.xml ~/.config/xfce4/xfconf/xfce-perchannel-xml/
    cp -f xfce/xfce4-desktop.xml ~/.config/xfce4/xfconf/xfce-perchannel-xml/
    cp -f xfce/thunar.xml ~/.config/xfce4/xfconf/xfce-perchannel-xml/
}

# Installing valuable fonts
installFonts() {
    section "Installing fonts"

    cd ~/tools/dotfiles/fonts

    # Copy fonts to desktop for backup
    cp -rf jetbrains.zip ~/Desktop/jetbrains
    cp -rf protonerd.zip ~/Desktop/protonerd

    # Install fonts
    sudo unzip jetbrains.zip -d /usr/share/fonts/truetype/jetbrains-mono
    sudo unzip protonerd.zip -d /usr/share/fonts/truetype/proto-nerd
    
    sudo fc-cache -f -v
}

# Running tools script
runToolsScript() {
    section "Running tools script"
    
    cd ~/tools/dotfiles
    
    # Assign execute permission and run tools script
    if [ -f shells/tools.sh ]; then
        chmod +x shells/tools.sh
        ./shells/tools.sh
    fi
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
    runToolsScript
    cloneDotfiles
    setupWallpapers
    createDirectories
    setupBinAndZsh
    setupUserThemes
    installFonts
    
    # Completion message
    success "All user configurations applied"
    info "Run: source ~/.zshrc"
    info "Then run: sudo ./setup-root.sh"
}

# Execute main function
main "$@"