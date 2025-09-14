export XDG_CONFIG_HOME="$HOME/.config"

# OH-MY-ZSH ###################################################################

export ZSH="$HOME/.oh-my-zsh"
export ZSH_THEME="candy"

plugins=(
    fzf
    git
    zsh-syntax-highlighting
    zsh-autosuggestions
    you-should-use
    docker
    tmux
    tmuxinator
    ssh
    zsh-interactive-cd
    httpie
    nvm
    npm
    pip
    python
    redis-cli
    postgres
    colored-man-pages
    cp
)

source $ZSH/oh-my-zsh.sh

# SOME INITS ##################################################################

# NVM
source /usr/share/nvm/init-nvm.sh
# Zoxide Init
eval "$(zoxide init zsh)"
# UV Init
eval "$(uv generate-shell-completion zsh)"
eval "$(uvx --generate-shell-completion zsh)"
# PIPX
eval "$(register-python-argcomplete pipx)"
# Autoenv
source /home/max/.nvm/versions/node/v22.15.1/lib/node_modules/@hyperupcall/autoenv/activate.sh
export AUTOENV_ENABLE_LEAVE=yes
# Generated for envman. Do not edit.
[ -s "$HOME/.config/envman/load.sh" ] && source "$HOME/.config/envman/load.sh"

# User configuration ##########################################################

bindkey -v

if [ -f ~/.host_specific_vars ]; then
    source ~/.host_specific_vars
fi

export PATH="$PATH:$HOME/.local/bin"
# Adding rust binaries to PATH
export PATH="$PATH:$HOME/.cargo/bin"
# Adding go binaries to PATH
export PATH="$PATH:$HOME/go/bin"
# Adding wsl VSCode to PATH
export PATH="$PATH:$WINHOME/AppData/Local/Programs/Microsoft VS Code/bin"
# Addind personal scripts to PATH
export PATH="$PATH:$HOME/bin"
export PATH="$PATH:$WINHOME/bin"

HISTFILE=~/.zsh_history
HISTSIZE=40000
SAVEHIST=999999999

unsetopt BEEP
setopt CORRECT

export TIME_STYLE=long-iso

export LC_CTYPE=en_DK.UTF-8
export LC_ALL=en_DK.UTF-8

export TERM="xterm-256color"

export PAGER=moar
export EDITOR=nvim
export SUDO_EDITOR=nvim
export GIT_EDITOR=nvim

export LESS='--mouse'

export FZF_DEFAULT_COMMAND='fd --type file --type dir --follow --hidden --color=always'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_DEFAULT_OPTS="--ansi"

# Bindings
bindkey -s ^f "tmux-sessionizer\n"

# Aliases
alias tmux="(TERM=tmux-256color; tmux)"
alias exp="/mnt/c/windows/explorer.exe"
alias pdftohtmldef="pdftohtml -s -i -noframes"
alias zshconfig="$EDITOR ~/.zshrc"
alias vim='nvim'
alias ssh-keygen-tagged='ssh-keygen -C "$(hostname)-$(date +%Y-%m-%d)"'
alias c='clear'
alias clip.exe='/mnt/c/Windows/System32/clip.exe'
alias clip='/mnt/c/Windows/System32/clip.exe'
alias copy='iconv -f UTF-8 -t UTF-16LE | /mnt/c/Windows/System32/clip.exe'
alias ed='ms-edit'
alias rm='echo "This is not the command you are looking for."; false'
alias t='trash'
alias py='uv run'

# Functions
cl() { cd "$@" && ls -A; }
zl() { z "$@" && ls -A; }
lf() {
    local selected
    selected=$(fzf --bind "start:reload:rg --files --color=never --encoding UTF-8")
    if [[ -n "$selected" ]]; then
        echo "$selected" | copy
    fi
}

# source '/home/max/.config/nvm/versions/node/v22.14.0/lib/node_modules/@hyperupcall/autoenv/activate.sh'
