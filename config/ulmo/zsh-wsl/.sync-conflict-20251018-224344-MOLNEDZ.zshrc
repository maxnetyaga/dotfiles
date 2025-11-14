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
    npm
    pip
    python
    redis-cli
    postgres
    colored-man-pages
    cp
    direnv
)

source $ZSH/oh-my-zsh.sh

# SOME INITS ##################################################################

# Zoxide Init
eval "$(zoxide init zsh)"
# UV Init
eval "$(uv generate-shell-completion zsh)"
eval "$(uvx --generate-shell-completion zsh)"
# PIPX
eval "$(register-python-argcomplete pipx)"
# Generated for envman. Do not edit.
[ -s "$HOME/.config/envman/load.sh" ] && source "$HOME/.config/envman/load.sh"
# NVM Init
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# User configuration ##########################################################

### vi mode ###

bindkey -v
export KEYTIMEOUT=1

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

if [ -f ~/.host_specific_vars ]; then
    source ~/.host_specific_vars
fi

### ### ###

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

export TIME_STYLE=long-iso

export LC_CTYPE=en_DK.UTF-8
export LC_ALL=en_DK.UTF-8

export TERM="xterm-256color"

export PAGER=moor
export EDITOR=nvim
export SUDO_EDITOR=nvim
export GIT_EDITOR=nvim

export LESS='--mouse'

export FZF_DEFAULT_COMMAND='fd --type file --type dir --follow --hidden --color=always'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_DEFAULT_OPTS="--ansi --style minimal --color 16 --layout=reverse --height=30% --preview='bat -p --color=always {}'"

# Bindings
bindkey -s ^f "tmux-sessionizer\n"

# Aliases
alias pdftohtmldef="pdftohtml -s -i -noframes"
alias vi='\vim'
alias vim='nvim'
alias ssh-keygen-tagged='ssh-keygen -C "$(hostname)-$(date +%Y-%m-%d)"'
alias t='trash'
alias confcolor='bat -p -l conf --pager=auto'
alias o='xdg-open'
e() {
    (nautilus -w $1 > /dev/null 2>&1 &);
}
cl() { cd "$@" && ls -A; }
zl() { z "$@" && ls -A; }
lf() {
    local selected
    selected=$(fzf --bind "start:reload:rg --files --color=never --encoding UTF-8")
    if [[ -n "$selected" ]]; then
        echo "$selected" | copy
    fi
}
