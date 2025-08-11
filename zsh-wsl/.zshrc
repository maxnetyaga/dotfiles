for i in "/mnt/wslg/runtime-dir/"*; do
  if [ ! -L "$XDG_RUNTIME_DIR$(basename "$i")" ]; then
    [ -d "$XDG_RUNTIME_DIR$(basename "$i")" ] && rm -r "$XDG_RUNTIME_DIR$(basename "$i")"
    ln -s "$i" "$XDG_RUNTIME_DIR$(basename "$i")"
  fi
done

export XDG_CONFIG_HOME="$HOME/.config"

### Inits ###------------------------------------------------------------------

# Oh-my-zsh Init
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="candy"

plugins=(
  git
  zsh-syntax-highlighting
  zsh-autosuggestions
  you-should-use
  docker
)
source $ZSH/oh-my-zsh.sh

# NVM Init
source /usr/share/nvm/init-nvm.sh

# Zoxide Init
eval "$(zoxide init zsh)"

# Uv Init
eval "$(uv generate-shell-completion zsh)"
eval "$(uvx --generate-shell-completion zsh)"

### User configuration ###-----------------------------------------------------

HISTFILE=~/.zsh_history
HISTSIZE=40000
SAVEHIST=999999999

unsetopt BEEP

export TIME_STYLE=long-iso

export LC_CTYPE=en_DK.UTF-8
export LC_ALL=en_DK.UTF-8

export TERM=xterm-256color

export PAGER=moar
export EDITOR='code --wait'
export SUDO_EDITOR='code --wait'
export GIT_EDITOR=nvim

export LESS='--mouse'

export WINHOME=$PATH:/mnt/c/Users/netya

# Adding rust binaries to PATH
export PATH="$PATH:$HOME/.cargo/bin"

# Adding go binaries to PATH
export PATH="$PATH:$HOME/go/bin"

# Addind personal scripts to PATH
export PATH="$PATH:$HOME/bin"

# Adding wsl VSCode to PATH
export PATH="$PATH:$WINHOME/AppData/Local/Programs/Microsoft VS Code/bin"

export PATH="$PATH:$HOME/.local/bin"

# Binds
bindkey -s ^f "tmux-sessionizer\n"

# Aliases
alias exp="/mnt/c/windows/explorer.exe"
alias pdftohtmldef="pdftohtml -s -i -noframes"
alias zshconfig="$EDITOR ~/.zshrc"
alias vim='nvim'
alias ssh-keygen-tagged='ssh-keygen -C "$(hostname)-$(date +%Y-%m-%d)"'
alias c='clear'
alias copy='iconv -f UTF-8 -t UTF-16LE | /mnt/c/Windows/System32/clip.exe'
alias ed='ms-edit'
alias rm='echo "This is not the command you are looking for."; false'
alias t='trash'
alias py='uv run'

# Functions
cl() { cd "$@" && ls -A; }
zl() { z "$@" && ls -A; }


# Generated for envman. Do not edit.
[ -s "$HOME/.config/envman/load.sh" ] && source "$HOME/.config/envman/load.sh"
