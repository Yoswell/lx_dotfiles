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
    "rlwrap" "remmina" "caido" "stegseek" "pngcheck" "sqlitebrowser" "cmake" "ghidra" "checksec" "stegsnow" "lxappearance" "rofi" 
    "kitty" "bloodyad" "certipy-ad" "python3-impacket" "impacket-scripts" "ranger" "flatpak" 
    "mono-devel" "wine" "wine64" "feroxbuster" "powershell" "gdb-peda" "wget" "gpg" "curl" "bat" "fd-find" "fzf" "ripgrep" 
    "jq" "yq" "ncdu" "html2text" "binwalk" "exiftool" "foremost" "sleuthkit" "wireshark" "tshark" 
    "tcpdump" "nmap" "nikto" "gobuster" "ffuf" "seclists" "wordlists" "radare2" "strace" "ltrace" "htop" 
    "tree" "libboost-all-dev" "polybar"
)

# Python pip packages
PIP_TOOLS=(
    "oletools" "stego-lsb" "pwntools" "pycryptodome" "decompyle3" "ropper" "pypykatz" "stegpy" "defaultcreds-cheat-sheet" 
    "kerbrute" "stegoveritas" "angr" "capstone" "unicorn" "keystone-engine" "stegcracker" "xortool" "droopescan"
)

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

# Main installation function
main() {
    if [ "$EUID" -eq 0 ]; then 
        warning "Do not run this script as root"
        exit 1
    fi
    
    # Create necessary directories
    mkdir -p ~/ctf_py_packages
    
    section "Starting Complete Installation"
    info "This script will install EVERYTHING without asking"
    warning "Press Enter to continue or Ctrl+C to cancel..."
    read -r
    
    # Installation sequence
    install_apt_tools
    install_pip_tools
    
    # Completion message
    section "Installation Complete"
    success "ALL tools have been installed/updated"
    info "Virtual environment: ~/ctf_py_packages/ctf_env"
    
    echo -e "${YELLOW}To activate the virtual environment:${NC}"
    echo -e "${GREEN}source ~/ctf_py_packages/ctf_env/bin/activate${NC}"
}

# Execute main function
main "$@"