# Enable the subsequent settings only in interactive sessions
case $- in
*i*) ;;
*) return ;;
esac

# Path to your oh-my-bash installation.
export OSH='/home/max/.oh-my-bash'

# Set name of the theme to load. Optionally, if you set this to "random"
# it'll load a random theme each time that oh-my-bash is loaded.
OSH_THEME="robbyrussell"

# Uncomment the following line to disable bi-weekly auto-update checks.
DISABLE_AUTO_UPDATE="true"

# * '[yyyy-mm-dd]'   # [yyyy-mm-dd] + [time] with colors
HIST_STAMPS='[yyyy-mm-dd]'

# Uncomment the following line if you do not want OMB to overwrite the existing
# aliases by the default OMB aliases defined in lib/*.sh
OMB_DEFAULT_ALIASES="check"

OMB_USE_SUDO=true

OMB_PROMPT_SHOW_PYTHON_VENV=true

# Modules #--------------------------------------------------------------------

completions=(
  git
)

aliases=(
  general
)

plugins=(
  git
)

#  if [ "$DISPLAY" ] || [ "$SSH" ]; then
#      plugins+=(tmux-autoattach)
#  fi

source "$OSH"/oh-my-bash.sh

# Program Inits #--------------------------------------------------------------

# NVM init
source /usr/share/nvm/init-nvm.sh

# Pyenv init
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init - bash)"

eval "$(zoxide init bash)"

# User configuration #---------------------------------------------------------

# Misc env vars
export TIME_STYLE=long-iso
export TERM=xterm-256color

export EDITOR=code
export SUDO_EDITOR="code --wait"
export GIT_EDITOR=nvim
export PAGER=moar
export LESS='--mouse'
export _ZO_DOCTOR=0

# Adding rust binaries to PATH
export PATH="$PATH:$HOME/.cargo/bin"
# Addind personal scripts to PATH
export PATH="$PATH:$HOME/bin"

# Aliases
alias pdftohtmldef="pdftohtml -s -i -noframes"
alias vim="nvim"
alias ssh-keygen-tagged='ssh-keygen -C "$(hostname)-$(date +%Y-%m-%d)"'
alias restow="stow -R"
alias wine-ru="LC_ALL='ru_RU.UTF-8' wine"

# Functions
cl() { cd "$@" && ls -A; }
zl() { z "$@" && ls -A; }
touch2() { mkdir -p "$(dirname "$1")" && touch "$1" ; }
reboot() { echo 'Reboot? (y/n)' && read x && [[ "$x" == "y" ]] && /sbin/reboot; }
