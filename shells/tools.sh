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

# APT packages
APT_TOOLS=(
    "rlwrap" "remmina" "caido" "stegseek" "pngcheck" "sqlitebrowser" 
    "cmake" "ghidra" "checksec" "stegsnow" "lxappearance" "rofi" 
    "kitty" "apt-transport-https" "windsurf" "bloodyad" "certipy-ad" 
    "python3-impacket" "impacket-scripts" "ranger" "flatpak" 
    "mono-devel" "wine" "wine64" "feroxbuster" "powershell"
    "gdb-peda" "wget" "gpg" "curl" "bat" "fd-find" "fzf" "ripgrep" 
    "jq" "yq" "hexyl" "ncdu" "html2text" "binwalk" "exiftool" 
    "foremost" "sleuthkit" "volatility" "wireshark" "tshark" 
    "tcpdump" "nmap" "nikto" "gobuster" "ffuf" "seclists" 
    "wordlists" "radare2" "strace" "ltrace" "neofetch" "htop" 
    "tree" "libboost-all-dev"
)

# Python pip packages
PIP_TOOLS=(
    "oletools" "stego-lsb" "pwntools" "pycryptodome" "decompyle3" 
    "decompyle6" "ropper" "pypykatz" "stegpy" "defaultcreds-cheat-sheet" 
    "kerbrute" "stegoveritas" "angr" "capstone" "unicorn" 
    "keystone-engine" "stegcracker" "xortool" "droopescan"
)

# Ruby packages
GEM_TOOLS=(
    "zsteg"
)

# Flatpack tools
FLATPAK_APPS=(
    "org.keepassxc.KeePassXC"
)

# Docker images
DOCKER_IMAGES=(
    "mcr.microsoft.com/dotnet/sdk:9.0"
)

# Micro editor plugins
MICRO_PLUGINS=(
    "gotham-colors"
    "editorconfig"
    "nordcolors"
    "filemanager"
)

# Special tool URLs (for easy updates)
TOOL_URLS=(
    "https://code.soundsoftware.ac.uk/attachments/download/2880/SonicVisualiser-5.2.1-x86_64.AppImage"
    "http://www.caesum.com/handbook/Stegsolve.jar"
    "https://github.com/lukechampine/jsteg/releases/download/v0.1.0/jsteg-linux-amd64"
    "https://github.com/java-decompiler/jd-gui/releases/download/v1.6.6/jd-gui-1.6.6.jar"
    "https://github.com/DissectMalware/pyOneNote/archive/master.zip"
)

# Git repositories for cloning
GIT_REPOS=(
    "https://github.com/danielcardeenas/AudioStego.git"
    "https://github.com/RobinDavid/LSB-Steganography.git"
    "https://github.com/MichaelSasser/pdfcrack-ng.git"
    "https://github.com/robertdavidgraham/masscan.git"
    "https://github.com/zrax/pycdc.git"
    "https://github.com/fortra/impacket.git"
)

# Function to setup Windsurf repository
setup_windsurf_repo() {
    section "Setting up Windsurf Repository"
    
    # Add Windsurf repository
    wget -qO- https://windsurf-stable.codeium.com/api/linux/apt/pubkey | gpg --dearmor | sudo tee /etc/apt/keyrings/windsurf-stable.gpg > /dev/null
    echo "deb [signed-by=/etc/apt/keyrings/windsurf-stable.gpg] https://windsurf-stable.codeium.com/apt/ stable main" | sudo tee /etc/apt/sources.list.d/windsurf.list
    success "Windsurf repository added"
}

# Function to install apt packages
install_apt_tools() {
    section "Installing APT Tools"
    
    sudo apt update
    info "Installing all APT packages: ${APT_TOOLS[*]}"
    sudo apt install -y "${APT_TOOLS[@]}" --fix-missing
    success "APT tools installation completed"
}

# Function to install pip packages in virtual environment
install_pip_tools() {
    section "Installing Python Tools"
    
    # Create/activate virtual environment
    python3 -m venv ~/ctf_py_packages/ctf_env
    success "Virtual environment created at ~/ctf_py_packages/ctf_env"
    
    # Activate virtual environment
    source ~/ctf_py_packages/ctf_env/bin/activate
    
    # Upgrade pip first
    pip install --upgrade pip
    
    info "Installing all Python packages: ${PIP_TOOLS[*]}"
    pip install --force-reinstall "${PIP_TOOLS[@]}"
    success "Python tools installation completed"
    
    # Special installation for pyOneNote
    info "Installing pyOneNote..."
    pip install --force-reinstall "https://github.com/DissectMalware/pyOneNote/archive/master.zip"
    
    # Deactivate virtual environment
    deactivate
}

# Function to install Ruby gems
install_gem_tools() {
    section "Installing Ruby Tools"
    
    for tool in "${GEM_TOOLS[@]}"; do
        info "Installing/Updating $tool..."
        sudo gem install --force "$tool"
        success "$tool installation completed"
    done
}

# Function to install Flatpak applications
install_flatpak() {
    section "Configuring Flatpak"
    
    # Add Flathub repository if not present
    info "Adding/Updating Flathub repository..."
    flatpak remote-add --user --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
    
    # Install Flatpak applications
    for app in "${FLATPAK_APPS[@]}"; do
        info "Installing/Updating $app..."
        flatpak install --user -y flathub "$app"
        success "$app installation completed"
    done
}

# Function to install Micro editor with plugins
install_micro_editor() {
    section "Installing Micro Editor"
    
    # Install Micro editor (force reinstall)
    info "Installing/Updating Micro editor..."
    curl -s https://getmic.ro | bash
    sudo mv -f micro /usr/bin/ 2>/dev/null || sudo cp micro /usr/bin/
    success "Micro editor installed/updated"
    
    # Install Micro plugins (force reinstall)
    info "Installing/Updating Micro plugins..."
    for plugin in "${MICRO_PLUGINS[@]}"; do
        info "Installing plugin: $plugin"
        micro -plugin install "$plugin" || micro -plugin update "$plugin"
    done
    
    success "Micro plugins installation completed"
}

# Function to install GDB plugins
install_gdb_plugins() {
    section "Installing GDB Plugins"
    
    # Install GEF
    info "Installing/Updating GEF..."
    bash -c "$(curl -fsSL https://gef.blah.cat/sh)"
    
    # Install pwndbg
    info "Installing/Updating pwndbg..."
    # Remove existing if any
    rm -rf pwndbg-gdb 2>/dev/null
    curl -qsL 'https://install.pwndbg.re' | sh -s -- -t pwndbg-gdb
    
    success "GDB plugins installation completed"
}

# Function to install special CTF tools
install_special_tools() {
    section "Installing Special CTF Tools"
    
    # Create tools directory
    mkdir -p ~/tools/ctftools
    cd ~/tools/ctftools || exit
    
    # Download tools from URLs
    info "Downloading special tools..."
    for url in "${TOOL_URLS[@]}"; do
        info "Downloading: $url"
        wget --no-clobber "$url" || wget "$url"
    done
    
    # Make AppImage executable
    chmod +x *.AppImage 2>/dev/null
    
    # Clone and build Git repositories
    info "Cloning Git repositories..."
    for repo in "${GIT_REPOS[@]}"; do
        repo_name=$(basename "$repo" .git)
        info "Cloning/Updating: $repo_name"
        
        if [ -d "$repo_name" ]; then
            cd "$repo_name" && git pull && cd ..
        else
            git clone "$repo"
        fi
    done
    
    # Build specific tools
    info "Building tools..."
    
    # Build masscan
    if [ -d "masscan" ]; then
        cd masscan && make && sudo make install && cd ..
    fi
    
    # Build pycdc
    if [ -d "pycdc" ]; then
        cd pycdc && cmake . && make && sudo make install && cd ..
    fi
    
    # Build impacket
    if [ -d "impacket" ]; then
        cd impacket && python3 -m pip install --force-reinstall . && cd ..
    fi
    
    success "Special tools installation completed"
}

# Function to pull Docker images
install_docker_images() {
    section "Pulling Docker Images"
    
    for image in "${DOCKER_IMAGES[@]}"; do
        info "Pulling Docker image: $image"
        sudo docker pull "$image"
    done
    
    success "Docker images pulled successfully"
}

# Main installation function
main() {
    if [ "$EUID" -eq 0 ]; then 
        warning "Do not run this script as root"
        exit 1
    fi
    
    # Create necessary directories
    mkdir -p ~/tools/ctftools
    mkdir -p ~/ctf_py_packages
    
    section "Starting Complete Installation"
    info "This script will install EVERYTHING without asking"
    warning "Press Enter to continue or Ctrl+C to cancel..."
    read -r
    
    # Installation sequence
    setup_windsurf_repo
    install_apt_tools
    install_pip_tools
    install_gem_tools
    install_flatpak
    install_micro_editor
    install_gdb_plugins
    install_special_tools
    install_docker_images
    
    # Completion message
    section "Installation Complete"
    success "ALL tools have been installed/updated"
    info "Virtual environment: ~/ctf_py_packages/ctf_env"
    info "Tools directory: ~/tools/ctftools"
    info "Total APT packages installed: ${#APT_TOOLS[@]}"
    info "Total Python packages installed: ${#PIP_TOOLS[@]}"
    
    echo -e "${YELLOW}To activate the virtual environment:${NC}"
    echo -e "  ${GREEN}source ~/ctf_py_packages/ctf_env/bin/activate${NC}"
    
    echo -e "${YELLOW}Don't forget to:${NC}"
    echo -e "  - Log out and back in for Flatpak apps to appear"
    echo -e "  - Configure your GDB plugins in ~/.gdbinit"
}

# Execute main function
main "$@"