#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
PURPLE='\033[0;35m'
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

# Global paths and variables
USER_HOME="/home/$USER"
TOOLS_DIR="$USER_HOME/tools"
DOTFILES_DIR="$TOOLS_DIR/dotfiles"
DOCUMENTS_DIR="$USER_HOME/Documents"
WALLPAPERS_DIR="$USER_HOME/Desktop/wallpapers"
THEMES_DIR="$USER_HOME/.themes"
MICRO_COLOR_DIR="$USER_HOME/.config/micro/colorschemes"
KITTY_DIR="$USER_HOME/.config/kitty"
XFCE_CONFIG_DIR="$USER_HOME/.config/xfce4/xfconf/xfce-perchannel-xml"
GTK_CONFIG_DIR="$USER_HOME/.config/gtk-3.0"
OH_MY_ZSH_DIR="$USER_HOME/.oh-my-zsh"
ZSH_CUSTOM_PLUGINS_DIR="$OH_MY_ZSH_DIR/custom/plugins"

# Wallpaper and theme file names
WALLPAPER_SNOW="snow.png"
LOGIN_BACKGROUND_KALI="/usr/share/backgrounds/kali/kali-maze-16x9.jpg"
LOGIN_BACKGROUND_LOGIN="/usr/share/backgrounds/kali/login.svg"

# Theme archives
THEME_MANTINIGHT_ARCHIVE="mantinight.tar"
THEME_DARKSUN_ARCHIVE="darksun.tar"

# Configuration file names
ZSH_RC_FILE="zshrc"
MICRO_THEME_FILE="micro_theme.micro"
KITTY_CONF_FILE="kitty.conf"
ROFI_THEME_FILE="rofi_theme.rasi"
XFCE_KEYBOARD_FILE="xfce4-keyboard-shortcuts.xml"
XFCE_POWER_FILE="xfce4-power-manager.xml"
XFCE_SETTINGS_FILE="xfce4Settings.xml"
GTK_SETTINGS_FILE="settings.ini"

# Dotfiles repositories and URLs
DOTFILES_REPO="https://github.com/Yoswell/dotfiles.git"
OH_MY_ZSH_INSTALL_URL="https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh"

# ZSH plugin repositories
ZSH_PLUGINS=(
    "zsh-autosuggestions|https://github.com/zsh-users/zsh-autosuggestions.git"
    "zsh-syntax-highlighting|https://github.com/zsh-users/zsh-syntax-highlighting.git"
    "zsh_tshark_autocomplete|https://github.com/Yoswell/zsh_tshark_autocomplete.git"
)

# Powerlevel10k theme repository
POWERLEVEL10K_REPO="https://github.com/romkatv/powerlevel10k.git"

# Font installation
FONT_DOWNLOADS_DIR="$USER_HOME/Downloads"
FONT_INSTALL_DIR="$USER_HOME/Desktop/jetbrains"
FONT_INSTALL_PATH="/usr/share/fonts/truetype/jetbrains-mono"
FONT_PATTERN="JetBrainsMono*.zip"

# Packages to uninstall
PACKAGES_TO_UNINSTALL=("vim" "nano")
SNAP_PACKAGES_TO_UNINSTALL=("autopsy")

# Directories to create in Documents
DOCUMENT_SUBDIRS=("htb_academy" "htb_apps" "htb_challenges" "testing")

# Main script
main() {
    echo -e "${CYAN}=== System Configuration Script ===${NC}\n"
    
    # Check if running as root
    if [ "$EUID" -eq 0 ]; then 
        warning "Do not run this script as root"
        exit 1
    fi
    
    # Execute all sections
    uninstall_packages
    setup_dotfiles
    configure_wallpapers
    create_directory_structure
    configure_bin_and_zsh
    configure_themes_and_appearance
    install_fonts
    execute_tools_script
    
    # Final message
    success "All configurations applied successfully!"
    info "Please run the following command to apply ZSH configuration:"
    echo -e "  source $USER_HOME/.zshrc"
    echo -e "\nSystem configuration complete! 🎉"
}

# Function: Uninstall packages
uninstall_packages() {
    section "Starting Uninstallations"
    
    # Uninstall APT packages
    for pkg in "${PACKAGES_TO_UNINSTALL[@]}"; do
        if command_exists "$pkg"; then
            sudo apt remove "$pkg" --purge -y
            success "$pkg uninstalled"
        else
            info "$pkg is not installed"
        fi
    done
    
    # Uninstall Snap packages
    if command_exists snap; then
        for snap_pkg in "${SNAP_PACKAGES_TO_UNINSTALL[@]}"; do
            if snap list | grep -q "$snap_pkg"; then
                sudo snap remove "$snap_pkg"
                success "$snap_pkg uninstalled"
            else
                info "$snap_pkg is not installed"
            fi
        done
    fi
}

# Function: Setup dotfiles
setup_dotfiles() {
    section "Cloning and Configuring Dotfiles"
    
    mkdir -p "$TOOLS_DIR"
    cd "$TOOLS_DIR"
    
    if [ -d "dotfiles" ]; then
        warning "Dotfiles directory exists. Removing and re-cloning..."
        rm -rf dotfiles
        success "Old dotfiles removed"
    fi
    
    git clone "$DOTFILES_REPO"
    success "Dotfiles cloned to $DOTFILES_DIR"
}

# Function: Configure wallpapers
configure_wallpapers() {
    section "Configuring Wallpapers"
    
    mkdir -p "$WALLPAPERS_DIR"
    
    if [ -d "$DOTFILES_DIR/wallpapers" ]; then
        cp -r "$DOTFILES_DIR/wallpapers"/* "$WALLPAPERS_DIR/"
        success "Wallpapers copied to $WALLPAPERS_DIR"
    else
        warning "Wallpapers directory not found in dotfiles"
    fi
    
    # Configure login wallpaper
    SNOW_IMAGE="$WALLPAPERS_DIR/$WALLPAPER_SNOW"
    if [ -f "$SNOW_IMAGE" ]; then
        sudo cp "$SNOW_IMAGE" "$LOGIN_BACKGROUND_KALI" 2>/dev/null || true
        sudo cp "$SNOW_IMAGE" "$LOGIN_BACKGROUND_LOGIN" 2>/dev/null || true
        success "Login wallpaper configured"
    else
        info "Snow image not found, skipping login wallpaper configuration"
    fi
}

# Function: Create directory structure
create_directory_structure() {
    section "Creating Directory Structure"
    
    cd "$DOCUMENTS_DIR"
    for dir in "${DOCUMENT_SUBDIRS[@]}"; do
        mkdir -p "$dir"
    done
    success "Directory structure created in $DOCUMENTS_DIR"
}

# Function: Configure BIN and ZSH
configure_bin_and_zsh() {
    section "Configuring BIN and ZSH"
    
    # Configure BIN directory
    if [ -d "$DOTFILES_DIR/bin" ]; then
        if [ -d "$USER_HOME/bin" ]; then
            warning "Existing bin directory found, removing..."
            rm -rf "$USER_HOME/bin"
        fi
        mv "$DOTFILES_DIR/bin" "$USER_HOME/"
        success "BIN directory configured"
    else
        warning "BIN directory not found in dotfiles"
    fi
    
    # Install Oh My Zsh
    if [ ! -d "$OH_MY_ZSH_DIR" ]; then
        info "Installing Oh My Zsh"
        sh -c "$(curl -fsSL $OH_MY_ZSH_INSTALL_URL)" "" --unattended
        success "Oh My Zsh installed"
    else
        info "Oh My Zsh already installed"
    fi
    
    # Install ZSH plugins
    if [ -d "$ZSH_CUSTOM_PLUGINS_DIR" ]; then
        info "Installing ZSH plugins"
        cd "$ZSH_CUSTOM_PLUGINS_DIR"
        
        for plugin_entry in "${ZSH_PLUGINS[@]}"; do
            IFS='|' read -r plugin_name plugin_url <<< "$plugin_entry"
            if [ ! -d "$plugin_name" ]; then
                git clone "$plugin_url" "$plugin_name"
                success "Plugin $plugin_name installed"
            else
                info "Plugin $plugin_name already installed"
            fi
        done
        success "ZSH plugins installation completed"
    fi
    
    # Install Powerlevel10k theme
    if [ -d "$OH_MY_ZSH_DIR" ]; then
        info "Installing Powerlevel10k theme"
        cd "$OH_MY_ZSH_DIR"
        if [ ! -d "powerlevel10k" ]; then
            git clone --depth=1 "$POWERLEVEL10K_REPO" powerlevel10k
            success "Powerlevel10k theme installed"
        else
            info "Powerlevel10k theme already installed"
        fi
    fi
    
    # Copy zshrc configuration
    if [ -f "$DOTFILES_DIR/$ZSH_RC_FILE" ]; then
        cp "$DOTFILES_DIR/$ZSH_RC_FILE" "$USER_HOME/.zshrc"
        success "ZSH configuration applied"
    else
        warning "$ZSH_RC_FILE not found in dotfiles"
    fi
    
    # Root user styling
    info "Configuring style for root user"
    if [ -d "$DOTFILES_DIR" ]; then
        sudo mkdir -p /root/.config/micro/colorschemes 2>/dev/null || true
        
        if [ -f "$DOTFILES_DIR/$ZSH_RC_FILE" ]; then
            sudo cp "$DOTFILES_DIR/$ZSH_RC_FILE" /root/.zshrc 2>/dev/null || true
        fi
        
        if [ -f "$DOTFILES_DIR/colorschemas/$MICRO_THEME_FILE" ]; then
            sudo cp "$DOTFILES_DIR/colorschemas/$MICRO_THEME_FILE" /root/.config/micro/colorschemes/$MICRO_THEME_FILE 2>/dev/null || true
        fi
        
        success "Root user configuration applied"
    else
        warning "Dotfiles directory not found for root configuration"
    fi
}

# Function: Configure themes and appearance
configure_themes_and_appearance() {
    section "Applying Appearance Configuration"
    
    # Create necessary directories
    mkdir -p "$THEMES_DIR" "$MICRO_COLOR_DIR" "$KITTY_DIR" "$XFCE_CONFIG_DIR" "$GTK_CONFIG_DIR"
    
    cd "$DOTFILES_DIR"
    
    # Theme installation: mantinight
    if [ -f "$DOTFILES_DIR/themes/$THEME_MANTINIGHT_ARCHIVE" ]; then
        info "Extracting mantinight theme"
        [ -d "$THEMES_DIR/mantinight" ] && rm -rf "$THEMES_DIR/mantinight"
        tar -xf "$DOTFILES_DIR/themes/$THEME_MANTINIGHT_ARCHIVE" -C "$THEMES_DIR"
        success "Mantinight theme installed"
    else
        warning "Mantinight theme archive not found"
    fi
    
    # Theme installation: darksun
    if [ -f "$DOTFILES_DIR/themes/$THEME_DARKSUN_ARCHIVE" ]; then
        info "Extracting darksun theme"
        [ -d "$THEMES_DIR/darksun" ] && rm -rf "$THEMES_DIR/darksun"
        tar -xf "$DOTFILES_DIR/themes/$THEME_DARKSUN_ARCHIVE" -C "$THEMES_DIR"
        success "Darksun theme installed"
    else
        warning "Darksun theme archive not found"
    fi
    
    # Micro editor theme configuration
    if [ -f "$DOTFILES_DIR/colorschemas/$MICRO_THEME_FILE" ]; then
        cp "$DOTFILES_DIR/colorschemas/$MICRO_THEME_FILE" "$MICRO_COLOR_DIR/"
        success "Micro theme configured"
    else
        warning "Micro theme file not found"
    fi
    
    # Kitty terminal configuration
    if [ -f "$DOTFILES_DIR/colorschemas/$KITTY_CONF_FILE" ]; then
        cp "$DOTFILES_DIR/colorschemas/$KITTY_CONF_FILE" "$KITTY_DIR/$KITTY_CONF_FILE"
        success "Kitty terminal configured"
    else
        warning "Kitty configuration file not found"
    fi
    
    # Rofi theme configuration
    if [ -f "$DOTFILES_DIR/themes/$ROFI_THEME_FILE" ]; then
        sudo cp -f "$DOTFILES_DIR/themes/$ROFI_THEME_FILE" /usr/share/rofi/themes/$ROFI_THEME_FILE 2>/dev/null || true
        success "Rofi theme configured"
    else
        warning "Rofi theme file not found"
    fi
    
    # XFCE configuration files
    if [ -f "$DOTFILES_DIR/xfce/$XFCE_KEYBOARD_FILE" ]; then
        cp "$DOTFILES_DIR/xfce/$XFCE_KEYBOARD_FILE" "$XFCE_CONFIG_DIR/"
        success "XFCE keyboard shortcuts configured"
    else
        warning "XFCE keyboard shortcuts file not found"
    fi
    
    if [ -f "$DOTFILES_DIR/xfce/$XFCE_POWER_FILE" ]; then
        cp "$DOTFILES_DIR/xfce/$XFCE_POWER_FILE" "$XFCE_CONFIG_DIR/"
        success "XFCE power manager configured"
    else
        warning "XFCE power manager file not found"
    fi
    
    if [ -f "$DOTFILES_DIR/xfce/$XFCE_SETTINGS_FILE" ]; then
        cp "$DOTFILES_DIR/xfce/$XFCE_SETTINGS_FILE" "$XFCE_CONFIG_DIR/"
        success "XFCE settings configured"
    else
        warning "XFCE settings file not found"
    fi
    
    # GTK configuration
    cat > "$GTK_CONFIG_DIR/$GTK_SETTINGS_FILE" << 'EOF_GTK'
[Settings]
gtk-theme-name=mantinight
gtk-application-prefer-dark-theme=1
EOF_GTK
    success "GTK configuration created"
    
    # Copy themes and configuration to root user
    info "Copying GTK themes and icons to /root/"
    
    if [ -d "$THEMES_DIR" ]; then
        sudo mkdir -p /root/.themes
        sudo cp -r "$THEMES_DIR"/* /root/.themes/ 2>/dev/null || true
        success "Themes copied to root"
    fi
    
    if [ -d "$USER_HOME/.icons" ]; then
        sudo mkdir -p /root/.icons
        sudo cp -r "$USER_HOME/.icons"/* /root/.icons/ 2>/dev/null || true
        success "Icons copied to root"
    fi
    
    if [ -f "$GTK_CONFIG_DIR/$GTK_SETTINGS_FILE" ]; then
        sudo mkdir -p /root/.config/gtk-3.0
        sudo cp "$GTK_CONFIG_DIR/$GTK_SETTINGS_FILE" /root/.config/gtk-3.0/ || true
        success "GTK settings copied to root"
    fi
}

# Function: Install fonts
install_fonts() {
    section "Installing JetBrains Mono Fonts"
    
    mkdir -p "$FONT_INSTALL_DIR"
    cd "$FONT_INSTALL_DIR"
    
    if ls "$FONT_DOWNLOADS_DIR"/$FONT_PATTERN 1> /dev/null 2>&1; then
        info "Unzipping and installing JetBrains Mono"
        unzip -o "$FONT_DOWNLOADS_DIR"/$FONT_PATTERN
        sudo mkdir -p "$FONT_INSTALL_PATH"
        sudo mv fonts/ttf/* "$FONT_INSTALL_PATH/" 2>/dev/null || true
        
        if command_exists fc-cache; then
            sudo fc-cache -f -v
            success "JetBrains Mono fonts installed and font cache updated"
        else
            success "JetBrains Mono fonts installed (font cache not updated)"
        fi
    else
        warning "Could not find $FONT_PATTERN file in $FONT_DOWNLOADS_DIR. Skipping font install."
    fi
    
    # Cleanup
    cd "$USER_HOME/Desktop"
    [ -d "$FONT_INSTALL_DIR" ] && rm -rf "$FONT_INSTALL_DIR"
    info "Font installation cleanup completed"
}

# Function: Execute tools script
execute_tools_script() {
    section "Installing Tools"
    
    TOOLS_SCRIPT="$DOTFILES_DIR/shells/tools.sh"
    
    if [ -f "$TOOLS_SCRIPT" ]; then
        info "Found tools installation script, executing..."
        chmod +x "$TOOLS_SCRIPT"
        "$TOOLS_SCRIPT"
        success "Tools installation script executed"
    else
        warning "Tools script not found in $DOTFILES_DIR/shells/"
    fi
}

# Execute main function
main "$@"
