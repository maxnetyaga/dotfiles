bindkey -r "^R"
export FZF_DEFAULT_COMMAND='fd --type file --type dir --follow --hidden --color=always'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_DEFAULT_OPTS="--ansi --style minimal --color 16 --layout=reverse --height=30% --preview='fzf-preview.sh {}'"
eval "$(fzf --zsh)"
