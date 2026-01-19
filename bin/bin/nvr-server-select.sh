#!/usr/bin/env bash

# list existing neovim servers, pick one via fzf, and attach to it via nvr

server_list=$(nvr --serverlist)
if [ -z "$server_list" ]; then
    nvim "$@"
    exit 0
fi

server=$(nvr --serverlist | fzf --prompt="Select nvr server: " --height=40%)

if [ -n "$server" ]; then
    nvr --servername "$server" "$@"
else
    echo "No server selected."
fi

