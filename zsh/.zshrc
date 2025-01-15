# Program Inits #--------------------------------------------------------------

# Oh-my-zsh Init
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="alanpeabody"
plugins=(git zsh-syntax-highlighting zsh-autosuggestions)
source $ZSH/oh-my-zsh.sh

# NVM Init
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] \
	&& printf %s "${HOME}/.nvm" \
	|| printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# PYENV Init
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PATH:$PYENV_ROOT/bin"
eval "$(pyenv init -)" 

# Zoxide Init
eval "$(zoxide init zsh)"


# User configuration #---------------------------------------------------------

# Misc env vars
export TIME_STYLE=long-iso

export TERM=xterm-256color

export ZSH_COMPDUMP=~/.cache/zsh/.zcompdump

export EDITOR=nvim
export GIT_EDITOR=nvim

export LESS='--mouse'

# Adding rust binaries to PATH
export PATH="$PATH:/home/netya/.cargo/bin"

# Addind personal scripths to PATH
export PATH="$PATH:/home/netya/Scripts"

# Aliases
alias exp="explorer.exe"
alias pdftohtmldef="pdftohtml -s -i -noframes"
alias zshconfig="$EDITOR ~/.zshrc"
alias vim="nvim"
alias ssh-keygen-tagged='ssh-keygen -C "$(hostname)-$(date +%Y-%m-%d)"'
