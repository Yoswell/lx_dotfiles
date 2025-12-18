#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
PURPLE='\033[0;35m'
NC='\033[0m'

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

# Create virtual environment
section "Creating Python Virtual Environment"
mkdir -p ~/ctf_py_packages
python3 -m venv ~/ctf_py_packages/ctf_env
source ~/ctf_py_packages/ctf_env/bin/activate
success "Virtual environment ctf_py_packages created successfully"

# Windsurf code editor
section "Installing Windsurf Code Editor"
sudo apt-get install wget gpg -y
wget -qO- "https://windsurf-stable.codeiumdata.com/wVxQEIWkwPUEAGf3/windsurf.gpg" | gpg --dearmor > windsurf-stable.gpg
sudo install -D -o root -g root -m 644 windsurf-stable.gpg /etc/apt/keyrings/windsurf-stable.gpg
echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/windsurf-stable.gpg] https://windsurf-stable.codeiumdata.com/wVxQEIWkwPUEAGf3/apt stable main" | sudo tee /etc/apt/sources.list.d/windsurf.list > /dev/null
sudo rm -f windsurf-stable.gpg
success "Windsurf repository added"

# Micro editor
section "Installing Micro Editor"
cd ~/tools
curl -s https://getmic.ro | bash
sudo cp ./micro /usr/bin
rm ./micro

micro -plugin install gotham-colors
micro -plugin install editorconfig
micro -plugin install nordcolors
micro -plugin install filemanager
success "Micro editor installed with plugins"

# Gdb plugins binary analyzer
section "Installing GDB Plugins"
sudo apt install gdb-peda -y
curl -qsL 'https://install.pwndbg.re' | sh -s -- -t pwndbg-gdb
bash -c "$(curl -fsSL https://gef.blah.cat/sh)"
success "GDB plugins installed (PEDA, pwndbg, GEF)"

# Apt install tools
section "Installing APT Packages"
sudo apt update
sudo apt install -y rlwrap remmina caido stegseek pngcheck sqlitebrowser cmake ghidra checksec stegsnow lxappearance rofi kitty apt-transport-https windsurf bloodyad certipy-ad python3-impacket impacket-scripts ranger flatpak mono-devel wine wine64 feroxbuster powershell
success "APT packages installed"

# Formatting utilities
section "Installing Formatting Utilities"
sudo apt install -y bat fd-find fzf ripgrep jq yq hexyl ncdu html2text
success "Formatting utilities installed"

# More CTF tools
section "Installing CTF Tools"
sudo apt install -y binwalk exiftool foremost sleuthkit volatility wireshark tshark tcpdump nmap nikto gobuster ffuf seclists wordlists radare2 strace ltrace neofetch htop tree
success "CTF tools installed"

# CTF tools pip (installed in virtual environment)
section "Installing Python CTF Tools"
pip install oletools stego-lsb pwntools pycryptodome decompyle3 decompyle6 ropper pypykatz stegpy defaultcreds-cheat-sheet kerbrute stegoveritas angr capstone unicorn keystone-engine stegcracker xortool droopescan
pip install -U https://github.com/DissectMalware/pyOneNote/archive/master.zip --force
stegoveritas_install_deps
success "Python CTF tools installed"

# Exit virtual environment after pip installations
deactivate

# Flatpak utils
section "Installing Flatpak Applications"
flatpak remote-add --user --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
flatpak install --user -y flathub org.keepassxc.KeePassXC
success "Flatpak applications installed"

# Sonic visualizer
section "Installing Sonic Visualizer"
mkdir -p ~/tools/ctftools
cd ~/tools/ctftools
curl -O https://code.soundsoftware.ac.uk/attachments/download/2880/SonicVisualiser-5.2.1-x86_64.AppImage
mv SonicVisualiser-5.2.1-x86_64.AppImage sonic.AppImage
chmod +x sonic.AppImage
success "Sonic Visualizer installed"

# JdGui
section "Installing JD-GUI"
curl -O https://github.com/java-decompiler/jd-gui/releases/download/v1.6.6/jd-gui-1.6.6.jar
mv jd-gui-1.6.6.jar jdGui.jar
chmod +x jdGui.jar
success "JD-GUI installed"

# Stegsolve
section "Installing Stegsolve"
wget http://www.caesum.com/handbook/Stegsolve.jar -O stegsolve.jar
chmod +x stegsolve.jar
success "Stegsolve installed"

# Jsteg
section "Installing Jsteg"
sudo wget -O /usr/bin/jsteg https://github.com/lukechampine/jsteg/releases/download/v0.1.0/jsteg-linux-amd64
sudo chmod +x /usr/bin/jsteg
success "Jsteg installed"

# Pdf cracker
section "Installing PDF Cracker"
cd ~/tools/ctftools
git clone https://github.com/MichaelSasser/pdfcrack-ng.git
cd pdfcrack-ng
mkdir build && cd build
cmake ..
make
success "PDF Cracker installed"

# Stego tools
section "Installing Stego Tools"
gem install zsteg
success "Zsteg installed"

# Audio stego
section "Installing Audio Stego Tools"
sudo apt-get install -y libboost-all-dev
cd ~/tools/ctftools
git clone https://github.com/danielcardeenas/AudioStego.git
mv AudioStego audioStego && cd audioStego
mkdir build && cd build
cmake ..
make
sudo ln -sf ~/tools/ctftools/audioStego/build/hideme /usr/bin/hideme
success "Audio Stego tools installed"

# LSB Steganography
section "Installing LSB Steganography"
cd ~/tools/ctftools
git clone https://github.com/RobinDavid/LSB-Steganography.git
cd LSB-Steganography
source ~/ctf_py_packages/ctf_env/bin/activate
pip install -r requirements.txt
deactivate
success "LSB Steganography installed"

# Masscan
section "Installing Masscan"
cd ~/tools/ctftools
git clone https://github.com/robertdavidgraham/masscan.git
cd masscan
make
success "Masscan installed"

# Pycdc
section "Installing Pycdc"
cd ~/tools/ctftools
git clone https://github.com/zrax/pycdc.git
cd pycdc
mkdir build && cd build
cmake ..
make
success "Pycdc installed"

# Impacket
section "Installing Impacket"
cd ~/tools/ctftools
git clone https://github.com/fortra/impacket.git
cd impacket
source ~/ctf_py_packages/ctf_env/bin/activate
pip install .
deactivate
cd ../
sudo rm -rf impacket
success "Impacket installed"

# Docker Images
section "Pulling Docker Images"
docker pull mcr.microsoft.com/dotnet/sdk:9.0
success "Docker images pulled"

# ---
# Finalization
# ---

success "All tools installed successfully"
info "Virtual environment created at: ~/ctf_py_packages/ctf_env"
echo -e "To activate the environment, run:"
echo -e "  source ~/ctf_py_packages/ctf_env/bin/activate"
echo -e "Tools directory: ~/tools/ctftools"
