source "$HOME/.path"

autoload -U colors && colors

function git_branch_name() {
    branch=$(git symbolic-ref HEAD 2>/dev/null | awk 'BEGIN{FS="/"} {print $NF}')
    if [[ $branch == "" ]]; then
        :
    else
        echo "[ $branch]"
    fi
}

setopt PROMPT_SUBST
prompt='%{$fg_bold[green]%}%n@%m %{$fg[blue]%}[%?] %{$reset_color%}%{$fg[white]%}[%~]%{$reset_color%} $(git_branch_name)
%{$fg[blue]%}->%{$fg_bold[blue]%} %#%{$reset_color%} '

HISTFILE=~/.zsh_history
HISTSIZE=40000
SAVEHIST=999999999

autoload -Uz compinit promptinit
compinit
promptinit

unsetopt BEEP
setopt extended_glob

autoload -Uz add-zsh-hook
clear_images() {
    printf "\x1b_Ga=d,d=A\x1b\\"
}
add-zsh-hook precmd clear_images

source "${0:h}/general/bindings.zsh"
source "${0:h}/general/aliases.zsh"
source "${0:h}/general/functions.zsh"

for i in ${0:h}/plugins/*; do
    source "$i"
done

source "${0:h}/general/functions.zsh"
