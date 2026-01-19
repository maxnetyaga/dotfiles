dir=$(basename "$PWD")
rnd=$(head /dev/urandom | tr -dc 'a-zA-Z0-9' | head -c 10)

socket=/tmp/nvim-"$dir"-"$rnd".sock

nvim --listen "$socket" "$@"
