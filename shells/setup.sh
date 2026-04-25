#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Log functions
success() {
    echo -e "${GREEN}[✓]${NC} :: $1" 
}

info() { 
    echo -e "${BLUE}[i]${NC} :: $1" 
}

warning() {
    echo -e "${YELLOW}[!]${NC} :: $1" 
}

error() {
    echo -e "${RED}[✗]${NC} :: $1" 
}

section() {
    echo -e "${CYAN}[ $1 ]${NC}" 
}

# Uninstalling packages
uninstallPackages() {
    section "Uninstalling packages"
    sudo apt remove vim nano --purge -y
    sudo apt autoremove -y
    sudo snap remove autopsy 2>/dev/null
}

# Cloning dotfiles
cloneDotfiles() {
    section "Cloning dotfiles"
    mkdir -p ~/tools
    cd ~/tools
    rm -rf dotfiles
    git clone https://github.com/Yoswell/dotfiles.git
    cd ~
}

# Setting up wallpapers
setupWallpapers() {
    section "Setting up wallpapers"
    mkdir -p ~/Desktop/wallpapers
    cp -rf ~/tools/dotfiles/wallpapers/* ~/Desktop/wallpapers/
    
    sudo cp -f ~/Desktop/wallpapers/snow.png /usr/share/backgrounds/kali/kali-maze-16x9.jpg
    sudo cp -f ~/Desktop/wallpapers/snow.png /usr/share/backgrounds/kali/login.svg
}

# Creating directories
createDirectories() {
    section "Creating directories"
    cd ~/Documents
    mkdir -p htb_academy htb_apps htb_challenges testing
}

# Setting up BIN and ZSH
setupBinAndZsh() {
    section "Setting up BIN and ZSH"
    
    # BIN directory
    rm -rf ~/bin
    cp -rf ~/tools/dotfiles/bin ~/
    chmod +x ~/bin/* 2>/dev/null
    
    # Oh My Zsh
    rm -rf ~/.oh-my-zsh
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    
    # ZSH plugins
    mkdir -p ~/.oh-my-zsh/custom/plugins
    cd ~/.oh-my-zsh/custom/plugins
    rm -rf zsh-autosuggestions zsh-syntax-highlighting zsh_tshark_autocomplete
    git clone https://github.com/zsh-users/zsh-autosuggestions.git
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git
    git clone https://github.com/Yoswell/zsh_tshark_autocomplete.git
    
    # Powerlevel10k
    cd ~/.oh-my-zsh
    rm -rf powerlevel10k
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git
    
    # ZSH config
    cp -f ~/tools/dotfiles/zshrc ~/.zshrc
    
    # Root user
    sudo mkdir -p /root/.config/micro/colorschemes
    sudo cp -f ~/tools/dotfiles/zshrc /root/.zshrc
}

# Setting up themes
setupThemes() {
    section "Setting up themes"
    
    # Create necessary directories
    mkdir -p ~/.themes
    mkdir -p ~/.config/micro/colorschemes
    mkdir -p ~/.config/kitty
    mkdir -p ~/.config/xfce4/xfconf/xfce-perchannel-xml
    mkdir -p ~/.config/gtk-3.0
    
    cd ~/tools/dotfiles
    
    # Extract themes from folders directory
    tar -xf themes/folders/mantinight.tar -C ~/.themes/
    tar -xf themes/folders/darksun.tar -C ~/.themes/
    
    # Copy configuration files from files directory
    cp -f themes/files/micro_theme.micro ~/.config/micro/colorschemes/
    cp -f themes/files/kitty.conf ~/.config/kitty/
    cp -f themes/files/tmux.conf ~/.tmux.conf
    cat themes/files/tilix.conf | dconf load /com/gexperts/Tilix/
    
    # Rofi theme
    sudo cp -f themes/files/rofi_theme.rasi /usr/share/rofi/themes/
    
    # XFCE configs
    cp -f xfce/xfce4-keyboard-shortcuts.xml ~/.config/xfce4/xfconf/xfce-perchannel-xml/
    cp -f xfce/xfce4-power-manager.xml ~/.config/xfce4/xfconf/xfce-perchannel-xml/
    cp -f xfce/xfce4Settings.xml ~/.config/xfce4/xfconf/xfce-perchannel-xml/
    
    # Copy to root
    sudo cp -rf ~/.themes/* /root/.themes/ 2>/dev/null
    sudo mkdir -p /root/.config/gtk-3.0
    sudo cp -f ~/.config/gtk-3.0/settings.ini /root/.config/gtk-3.0/ 2>/dev/null
}

# Installing fonts
installFonts() {
    section "Installing fonts"
    
    mkdir -p ~/Desktop/jetbrains
    cd ~/Desktop/jetbrains
    
    # Extract all JetBrains Mono zip files
    for zip in ~/Downloads/JetBrainsMono*.zip; do
        [ -f "$zip" ] && unzip -o "$zip"
    done
    
    sudo mkdir -p /usr/share/fonts/truetype/jetbrains-mono
    find . -name "*.ttf" -exec sudo cp -f {} /usr/share/fonts/truetype/jetbrains-mono/ \;
    sudo fc-cache -f -v
    
    cd ~/Desktop
    rm -rf jetbrains
}

# Running tools script
runToolsScript() {
    section "Running tools script"
    
    if [ -f ~/tools/dotfiles/shells/tools.sh ]; then
        chmod +x ~/tools/dotfiles/shells/tools.sh
        ~/tools/dotfiles/shells/tools.sh
    fi
}

main() {
    if [ "$EUID" -eq 0 ]; then
        warning "Do not run as root"
        exit 1
    fi
    
    section "Starting Complete Setup"
    info "This script will install EVERYTHING without asking"
    warning "Press Enter to continue or Ctrl+C to cancel..."
    read -r
    
    # Installation sequence
    uninstallPackages
    cloneDotfiles
    setupWallpapers
    createDirectories
    setupBinAndZsh
    setupThemes
    installFonts
    runToolsScript
    
    # Completion message
    success "All configurations applied"
    info "Run: source ~/.zshrc"
}

# Execute main function
main "$@"