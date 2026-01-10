# zshrc custom plugins, functions and themes
#   cp zshrc ~/.zshrc

# Powerlevel10k
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
    source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
source ~/.oh-my-zsh/powerlevel10k/powerlevel10k.zsh-theme

# Disable updates
DISABLE_AUTO_UPDATE="true"

# Completed cache
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.zsh/cache

# Paths
export PATH=~/.local/bin:/snap/bin:/usr/sandbox/:/home/kali/.local/share/gem/ruby/3.3.0/bin:/usr/local/bin:/usr/bin:/bin:/usr/local/games:/usr/games:/usr/share/games:/usr/local/sbin:/usr/sbin:/sbin:$PATH
export PATH="$HOME/bin/:$PATH"
export ZSH=$HOME/.oh-my-zsh

# Themas oh-my-zsh
# ZSH_THEME="evan"
# ZSH_THEME="powerlevel10k/powerlevel10k"

# Functions
function hexd() { echo "$@" | xxd -p -r }
function b64() { echo "$@" | base64 -d }
function mkt() { mkdir {content,nmap,credentials,exploits} }
function py() { python3 -c "$@" }
function getDate() { date -d "$(wget --method=HEAD -qSO- --max-redirect=0 $@ 2>&1 | sed -n 's/^ *Date: *//p')" "+%Y-%m-%d %H:%M:%S" }
function getPorts() { echo "$@" | awk -F '/' '{print $1}' | sed -z 's/\n/,/g' }

function reload() {
    sudo apt autoremove
    sudo apt clean
    sudo journalctl --vacuum-time=5d
    sync
    sudo tee /proc/sys/vm/drop_caches > /dev/null
}

# Aliases
alias ll='ls -l'
alias la='ls -la'
alias cls="clear"
alias dir='dir --color=auto'
alias vdir='vdir --color=auto'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias bat='batcat --theme="base16" -l c'
alias stopVpn='sudo killall openvpn'
alias rmall='sudo rm -r'

# Plugins
plugins=(
    zsh-syntax-highlighting
    zsh-autosuggestions
)

source ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

if [ -f /usr/share/zsh-autocomplete/zsh-autocomplete.plugin.zsh ]; then
    source /usr/share/zsh-autocomplete/zsh-autocomplete.plugin.zsh
    zstyle ':autocomplete:tab:*' insert-unambiguous yes
    zstyle ':autocomplete:tab:*' widget-style menu-select
    zstyle ':autocomplete:*' min-input 1000
    bindkey $key[Up] up-line-or-history
    bindkey $key[Down] down-line-or-history
fi

source $ZSH/oh-my-zsh.sh
