# Powerlevel10k terminal theme
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
source ~/.oh-my-zsh/custom/themes/powerlevel10k/powerlevel10k.zsh-theme

# Disable updates
DISABLE_AUTO_UPDATE="true"

# Completed cache
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.zsh/cache

# Environment paths
# Variables individuales de rutas
P01="$HOME/.local/bin"
P02="$HOME/.local/share/gem/ruby/3.3.0/bin"
P03="$HOME/bin/"
P04="/snap/bin"
P05="/usr/sandbox/"
P06="/usr/local/bin"
P07="/usr/bin"
P08="/bin"
P09="/usr/local/games"
P10="/usr/games"
P11="/usr/share/games"
P12="/usr/local/sbin"
P13="/usr/sbin"
P14="/sbin"

# PATH principal combinando todas
export PATH="$P01:$P02:$P03:$P04:$P05:$P06:$P07:$P08:$P09:$P10:$P11:$P12:$P13:$P14:$PATH"

# ZSH (sin cambios)
export ZSH=$HOME/.oh-my-zsh

# Themas oh-my-zsh
# ZSH_THEME="powerlevel10k/powerlevel10k"
ZSH_COLORIZE_STYLE="colorful"

# Functions
function hexd() { 
  echo "$@" | xxd -p -r
}

function b64() { 
  echo "$@" | base64 -d
}

function mkt() { 
  mkdir {content,nmap,credentials,exploits} 
}

function py() { 
  python3 -c "$@"
}

function getDate() { 
  date -d "$(wget --method=HEAD -qSO- --max-redirect=0 $@ 2>&1 | sed -n 's/^ *Date: *//p')" "+%Y-%m-%d %H:%M:%S"
}

function getPorts() { 
  echo "$@" | awk -F '/' '{print $1}' | sed -z 's/\n/,/g'
}

function reload() {
  sudo apt autoremove
  sudo apt clean
  sudo journalctl --vacuum-time=5d
  sync
  sudo tee /proc/sys/vm/drop_caches > /dev/null
}

# Local aliases
alias bat='batcat --theme="base16" -l c'
alias stopVpn='sudo killall openvpn'
alias rmall='sudo rm -r'
alias ll='ls -l'
alias la='ls -la'
alias cls="clear"
alias dir='dir --color=auto'
alias vdir='vdir --color=auto'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# Local plugins
plugins=(
  zsh-syntax-highlighting
  zsh-autosuggestions
  zsh_tshark_autocomplete
  colorize
  git
)

source ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

if [ -f ~/.oh-my-zsh/custom/plugins/zsh_tshark_autocomplete/zsh_tshark_autocomplete.plugin.zsh ]; then
  source ~/.oh-my-zsh/custom/plugins/zsh_tshark_autocomplete/zsh_tshark_autocomplete.plugin.zsh
  zstyle ':autocomplete:tab:*' insert-unambiguous yes
  zstyle ':autocomplete:tab:*' widget-style menu-select
  zstyle ':autocomplete:*' min-input 1000
  bindkey $key[Up] up-line-or-history
  bindkey $key[Down] down-line-or-history
fi

source $ZSH/oh-my-zsh.sh
