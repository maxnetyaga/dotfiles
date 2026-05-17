o() { (xdg-open $@ >/dev/null 2>&1 &) }

e() {
    (nautilus -w $1 >/dev/null 2>&1 &)
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

pick() {
    readlink --canonicalize "$@" | wl-copy
}
compdef _files pick
