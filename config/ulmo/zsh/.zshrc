export XDG_CONFIG_HOME="$HOME/.config"

# OH-MY-ZSH ###################################################################

export ZSH="$HOME/.oh-my-zsh"

plugins=(
    zsh-vi-mode
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

export PS1="%{$fg_bold[green]%}%n@%m %{$fg[blue]%}[exit %?] %{$reset_color%}%{$fg[white]%}[%~]%{$reset_color%} $(git_prompt_info)
%{$fg[blue]%}->%{$fg_bold[blue]%} %#%{$reset_color%} "

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
setopt extended_glob

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
export FZF_DEFAULT_OPTS="--ansi --style minimal --color 16 --layout=reverse --height=30% --preview='fzf-preview.sh {}'"

# Bindings
bindkey -s '^f' "tmux-sessionizer\n"

# Aliases
alias pdftohtmldef="pdftohtml -s -i -noframes"
alias vi='\vim'
alias vim='nvim-with-dir-socket.sh'
alias nvr='nvr-server-select.sh'
alias ssh-keygen-tagged='ssh-keygen -C "$(hostname)-$(date +%Y-%m-%d)"'
alias t='trash'
alias confcolor='bat -p -l conf --pager=auto'
alias o='xdg-open'
alias ll='eza -l'
alias la='eza -la'
alias clist=$'cliphist list | sed \'s/^.*\t//\' | tac'
e() {
    (nautilus -w $1 > /dev/null 2>&1 &);
}
cl() { cd "$@" && ls -A; }
rcd() {
    tmpfile="$(mktemp -t ranger_cd.XXXXXX)"
    ranger --choosedir="$tmpfile" "$@"
    if [ -f "$tmpfile" ]; then
        dir="$(cat "$tmpfile")"
        rm -f "$tmpfile"
        [ -d "$dir" ] && cd "$dir"
    fi
}
zl() { z "$@" && ls -A; }
lf() {
    local selected
    selected=$(fzf --bind "start:reload:rg --files --color=never --encoding UTF-8")
    if [[ -n "$selected" ]]; then
        echo "$selected" | copy
    fi
}

autoload -Uz add-zsh-hook
clear_images() {
    printf "\x1b_Ga=d,d=A\x1b\\"
}
add-zsh-hook precmd clear_images

## [Completion]
## Completion scripts setup. Remove the following line to uninstall
[[ -f /home/max/.config/.dart-cli-completion/zsh-config.zsh ]] && . /home/max/.config/.dart-cli-completion/zsh-config.zsh || true
## [/Completion]

export SSH_AUTH_SOCK=$XDG_RUNTIME_DIR/gcr/ssh
