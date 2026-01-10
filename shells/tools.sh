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
    "gdb-peda" "wget" "gpg" "curl"
    "bat" "fd-find" "fzf" "ripgrep" "jq" "yq" "hexyl" "ncdu" "html2text"
    "binwalk" "exiftool" "foremost" "sleuthkit" "volatility" 
    "wireshark" "tshark" "tcpdump" "nmap" "nikto" "gobuster" 
    "ffuf" "seclists" "wordlists" "radare2" "strace" "ltrace" 
    "neofetch" "htop" "tree" "libboost-all-dev"
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
    "sonic|https://code.soundsoftware.ac.uk/attachments/download/2880/SonicVisualiser-5.2.1-x86_64.AppImage"
    "stegsolve|http://www.caesum.com/handbook/Stegsolve.jar"
    "jsteg|https://github.com/lukechampine/jsteg/releases/download/v0.1.0/jsteg-linux-amd64"
    "jdgui|https://github.com/java-decompiler/jd-gui/releases/download/v1.6.6/jd-gui-1.6.6.jar"
    "pyonenote|https://github.com/DissectMalware/pyOneNote/archive/master.zip"
)

# Git repositories for cloning
GIT_REPOS=(
    "audioStego|https://github.com/danielcardeenas/AudioStego.git"
    "LSB-Steganography|https://github.com/RobinDavid/LSB-Steganography.git"
    "pdfcrack-ng|https://github.com/MichaelSasser/pdfcrack-ng.git"
    "masscan|https://github.com/robertdavidgraham/masscan.git"
    "pycdc|https://github.com/zrax/pycdc.git"
    "impacket|https://github.com/fortra/impacket.git"
)

# Installation check functions
is_installed_apt() {
    dpkg -l "$1" 2>/dev/null | grep -q "^ii" || dpkg -l | grep -q "^ii.*$1"
}

is_installed_pip() {
    pip show "$1" >/dev/null 2>&1
}

is_installed_gem() {
    gem list | grep -q "^$1 "
}

is_installed_flatpak() {
    flatpak list --app | grep -q "$1"
}

is_docker_image_pulled() {
    docker images --format "{{.Repository}}:{{.Tag}}" | grep -q "^$1$"
}

is_micro_plugin_installed() {
    micro -plugin list 2>/dev/null | grep -q "$1"
}

# Function to install apt packages
install_apt_tools() {
    section "Installing APT Tools"
    local to_install=()
    
    # Check which tools need installation
    for tool in "${APT_TOOLS[@]}"; do
        if is_installed_apt "$tool"; then
            info "$tool is already installed"
        else
            to_install+=("$tool")
        fi
    done
    
    # Install missing tools
    if [ ${#to_install[@]} -gt 0 ]; then
        info "Installing: ${to_install[*]}"
        sudo apt update
        sudo apt install -y "${to_install[@]}"
        success "APT tools installed successfully"
    else
        info "All APT tools are already installed"
    fi
}

# Function to install pip packages in virtual environment
install_pip_tools() {
    section "Installing Python Tools"
    
    # Create/activate virtual environment
    if [ ! -d ~/ctf_py_packages/ctf_env ]; then
        info "Creating Python virtual environment..."
        python3 -m venv ~/ctf_py_packages/ctf_env
        success "Virtual environment created at ~/ctf_py_packages/ctf_env"
    fi
    
    # Activate virtual environment
    source ~/ctf_py_packages/ctf_env/bin/activate
    
    local to_install=()
    
    # Check which pip tools need installation
    for tool in "${PIP_TOOLS[@]}"; do
        if is_installed_pip "$tool"; then
            info "$tool is already installed"
        else
            to_install+=("$tool")
        fi
    done
    
    # Install missing pip tools
    if [ ${#to_install[@]} -gt 0 ]; then
        info "Installing: ${to_install[*]}"
        pip install "${to_install[@]}"
        success "Python tools installed successfully"
    else
        info "All Python tools are already installed"
    fi
    
    # Special installation for pyOneNote
    info "Installing pyOneNote..."
    pip install -U "https://github.com/DissectMalware/pyOneNote/archive/master.zip" --force
    
    # Deactivate virtual environment
    deactivate
}

# Function to install Ruby gems
install_gem_tools() {
    section "Installing Ruby Tools"
    
    for tool in "${GEM_TOOLS[@]}"; do
        if is_installed_gem "$tool"; then
            info "$tool is already installed"
        else
            info "Installing $tool..."
            sudo gem install "$tool"
            success "$tool installed successfully"
        fi
    done
}

# Function to install Flatpak applications
install_flatpak() {
    section "Configuring Flatpak"
    
    # Add Flathub repository if not present
    if ! flatpak remote-list | grep -q flathub; then
        info "Adding Flathub repository..."
        flatpak remote-add --user --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
        success "Flathub repository added"
    fi
    
    # Install Flatpak applications
    for app in "${FLATPAK_APPS[@]}"; do
        if is_installed_flatpak "$app"; then
            info "$app is already installed"
        else
            info "Installing $app..."
            flatpak install --user -y flathub "$app"
            success "$app installed successfully"
        fi
    done
}

# Function to install Micro editor with plugins
install_micro_editor() {
    section "Installing Micro Editor"
    
    # Check if Micro is already installed
    if command -v micro &> /dev/null; then
        info "Micro editor is already installed"
    else
        info "Installing Micro editor..."
        curl -s https://getmic.ro | bash
        sudo mv micro /usr/bin/
        success "Micro editor installed"
    fi
    
    # Install Micro plugins
    info "Installing Micro plugins..."
    local plugins_installed=0
    
    for plugin in "${MICRO_PLUGINS[@]}"; do
        if is_micro_plugin_installed "$plugin"; then
            info "Plugin $plugin is already installed"
        else
            info "Installing plugin: $plugin"
            micro -plugin install "$plugin"
            plugins_installed=$((plugins_installed + 1))
        fi
    done
    
    if [ $plugins_installed -gt 0 ]; then
        success "Installed $plugins_installed Micro plugins"
    else
        info "All Micro plugins are already installed"
    fi
}

# Function to install GDB plugins
install_gdb_plugins() {
    section "Installing GDB Plugins"
    
    # Check and install GEF
    if [ ! -f ~/.gdbinit-gef.py ] && [ ! -f ~/.gdbinit ]; then
        info "Installing GEF..."
        bash -c "$(curl -fsSL https://gef.blah.cat/sh)"
    else
        info "GEF is already installed or configured"
    fi
    
    # Check and install pwndbg
    if [ ! -d ~/.pwndbg ]; then
        info "Installing pwndbg..."
        curl -qsL 'https://install.pwndbg.re' | sh -s -- -t pwndbg-gdb
    else
        info "pwndbg is already installed"
    fi
    
    success "GDB plugins installation completed"
}

# Function to download tools from URLs
download_tool() {
    local tool_name=$1
    local url=$2
    local output_file=$3
    
    case $tool_name in
        sonic)
            if [ ! -f ~/tools/ctftools/sonic.AppImage ]; then
                info "Downloading Sonic Visualizer..."
                curl -L -o sonic.AppImage "$url"
                chmod +x sonic.AppImage
                success "Sonic Visualizer downloaded"
            fi
            ;;
        stegsolve)
            if [ ! -f ~/tools/ctftools/stegsolve.jar ]; then
                info "Downloading Stegsolve..."
                wget -O stegsolve.jar "$url"
                chmod +x stegsolve.jar
                success "Stegsolve downloaded"
            fi
            ;;
        jsteg)
            if ! command -v jsteg &> /dev/null; then
                info "Downloading Jsteg..."
                sudo wget -O /usr/bin/jsteg "$url"
                sudo chmod +x /usr/bin/jsteg
                success "Jsteg downloaded and installed"
            fi
            ;;
        jdgui)
            if [ ! -f ~/tools/ctftools/jdGui.jar ]; then
                info "Downloading JD-GUI..."
                curl -L -o jdGui.jar "$url"
                chmod +x jdGui.jar
                success "JD-GUI downloaded"
            fi
            ;;
    esac
}

# Function to clone and build Git repositories
clone_and_build_repo() {
    local repo_name=$1
    local repo_url=$2
    
    case $repo_name in
        audioStego)
            if [ ! -d ~/tools/ctftools/audioStego ]; then
                info "Cloning Audio Stego..."
                git clone "$repo_url"
                mv AudioStego audioStego
                cd audioStego
                mkdir build && cd build
                cmake .. && make
                sudo ln -sf ~/tools/ctftools/audioStego/build/hideme /usr/bin/hideme
                cd ../..
                success "Audio Stego built and installed"
            fi
            ;;
        LSB-Steganography)
            if [ ! -d ~/tools/ctftools/LSB-Steganography ]; then
                info "Cloning LSB Steganography..."
                git clone "$repo_url"
                cd LSB-Steganography
                source ~/ctf_py_packages/ctf_env/bin/activate
                pip install -r requirements.txt
                deactivate
                cd ..
                success "LSB Steganography installed"
            fi
            ;;
        pdfcrack-ng)
            if [ ! -d ~/tools/ctftools/pdfcrack-ng ]; then
                info "Cloning PDF Cracker..."
                git clone "$repo_url"
                cd pdfcrack-ng
                mkdir build && cd build
                cmake .. && make
                cd ../..
                success "PDF Cracker built"
            fi
            ;;
        masscan)
            if [ ! -d ~/tools/ctftools/masscan ]; then
                info "Cloning Masscan..."
                git clone "$repo_url"
                cd masscan && make && cd ..
                success "Masscan built"
            fi
            ;;
        pycdc)
            if [ ! -d ~/tools/ctftools/pycdc ]; then
                info "Cloning Pycdc..."
                git clone "$repo_url"
                cd pycdc
                mkdir build && cd build
                cmake .. && make
                cd ../..
                success "Pycdc built"
            fi
            ;;
        impacket)
            if [ ! -d ~/tools/ctftools/impacket ]; then
                info "Cloning Impacket..."
                git clone "$repo_url"
                cd impacket
                source ~/ctf_py_packages/ctf_env/bin/activate
                pip install .
                deactivate
                cd .. && rm -rf impacket
                success "Impacket installed"
            fi
            ;;
    esac
}

# Function to install special CTF tools
install_special_tools() {
    section "Installing Special CTF Tools"
    
    # Create tools directory
    mkdir -p ~/tools/ctftools
    cd ~/tools/ctftools
    
    # Download tools from URLs
    for url_entry in "${TOOL_URLS[@]}"; do
        IFS='|' read -r tool_name url <<< "$url_entry"
        download_tool "$tool_name" "$url"
    done
    
    # Clone and build Git repositories
    for repo_entry in "${GIT_REPOS[@]}"; do
        IFS='|' read -r repo_name repo_url <<< "$repo_entry"
        clone_and_build_repo "$repo_name" "$repo_url"
    done
    
    success "Special tools installation completed"
}

# Function to pull Docker images
install_docker_images() {
    section "Pulling Docker Images"
    
    for image in "${DOCKER_IMAGES[@]}"; do
        if is_docker_image_pulled "$image"; then
            info "$image is already pulled"
        else
            info "Pulling $image..."
            docker pull "$image"
            success "$image pulled successfully"
        fi
    done
}

# Function to setup Windsurf repository
setup_windsurf_repo() {
    section "Setting up Windsurf Repository"
    
    if ! is_installed_apt "windsurf"; then
        info "Adding Windsurf repository..."
        wget -qO- "https://windsurf-stable.codeiumdata.com/wVxQEIWkwPUEAGf3/windsurf.gpg" | gpg --dearmor > windsurf-stable.gpg
        sudo install -D -o root -g root -m 644 windsurf-stable.gpg /etc/apt/keyrings/windsurf-stable.gpg
        echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/windsurf-stable.gpg] https://windsurf-stable.codeiumdata.com/wVxQEIWkwPUEAGf3/apt stable main" | sudo tee /etc/apt/sources.list.d/windsurf.list > /dev/null
        rm -f windsurf-stable.gpg
        success "Windsurf repository added"
    else
        info "Windsurf repository already configured"
    fi
}

# Main installation function
main() {
		# Check if running as root
    if [ "$EUID" -eq 0 ]; then 
        warning "Do not run this script as root"
        exit 1
    fi
    
    # Update repositories first
    section "Updating System Repositories"
    sudo apt update
    
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
    success "All tools have been installed/verified"
    info "Virtual environment: ~/ctf_py_packages/ctf_env"
    info "Tools directory: ~/tools/ctftools"
    echo -e "To activate the virtual environment, run:"
    echo -e "  ${GREEN}source ~/ctf_py_packages/ctf_env/bin/activate${NC}"
}

# Execute main function
main "$@"
