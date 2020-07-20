stty -ixon

ZSH_THEME="agnoster"
# Remove long host name
DEFAULT_USER=`whoami`

# Path to your oh-my-zsh installation.
export ZSH=~/.config/ohmyzsh

# SSH Key Path
export SSH_KEY_PATH="~/.ssh/id_rsa"
# Default Editor
export EDITOR="vim"
# Default Browser
export BROWSER="chrome"
# You may need to manually set your language environment
export LANG=en_GB.UTF-8
# Uncomment the following line to change how often to auto-update (in days).
export UPDATE_ZSH_DAYS=90

# History in cache directory:
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.cache/.zsh_history

# Enable colors and change prompt:
autoload -U colors && colors

# Basic auto/tab complete:
autoload -U compinit
zstyle ':completion:*' menu select
zmodload zsh/complist
compinit
_comp_options+=(globdots)		# Include hidden files.

# vi mode
bindkey -v
export KEYTIMEOUT=1

# Use vim keys in tab complete menu:
bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char
bindkey -M menuselect 'j' vi-down-line-or-history
bindkey -v '^?' backward-delete-char

# Change cursor shape for different vi modes.
function zle-keymap-select {
  if [[ ${KEYMAP} == vicmd ]] ||
     [[ $1 = 'block' ]]; then
    echo -ne '\e[1 q'
  elif [[ ${KEYMAP} == main ]] ||
       [[ ${KEYMAP} == viins ]] ||
       [[ ${KEYMAP} = '' ]] ||
       [[ $1 = 'beam' ]]; then
    echo -ne '\e[5 q'
  fi
}
zle -N zle-keymap-select
zle-line-init() {
    zle -K viins # initiate `vi insert` as keymap (can be removed if `bindkey -V` has been set elsewhere)
    echo -ne "\e[5 q"
}
zle -N zle-line-init
echo -ne '\e[5 q' # Use beam shape cursor on startup.
preexec() { echo -ne '\e[5 q' ;} # Use beam shape cursor for each new prompt.

# Edit line in vim with ctrl-e:
autoload edit-command-line; zle -N edit-command-line
bindkey '^e' edit-command-line

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"
plugins=(
  git
  archlinux
  web-search
	docker
	laravel5
  systemd
 	sudo
 	sublime
)


prompt_dir() {
  prompt_segment blue black "${PWD##*/}"
}

# ssh-completions
h=()
if [[ -r ~/.ssh/config ]]; then
  h=($h ${${${(@M)${(f)"$(cat ~/.ssh/config)"}:#Host *}#Host }:#*[*?]*})
fi
if [[ -r ~/.ssh/known_hosts ]]; then
  h=($h ${${${(f)"$(cat ~/.ssh/known_hosts{,2} || true)"}%%\ *}%%,*}) 2>/dev/null
fi
if [[ $#h -gt 0 ]]; then
  zstyle ':completion:*:ssh:*' hosts $h
  zstyle ':completion:*:slogin:*' hosts $h
fi

if which ruby >/dev/null && which gem >/dev/null; then
	export PATH="$(ruby -r rubygems -e 'puts Gem.user_dir')/bin:$PATH"
fi

# Oh-my-zsh
source $ZSH/oh-my-zsh.sh
# Load zsh-syntax-highlighting; should be last.
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh 2>/dev/null
# Load aliases
source "$HOME/.config/.aliasrc"
# Load Node version management
if [ -d "$HOME/.nvm" ]; then
  source "$HOME/.nvm/nvm.sh"
fi
