#!/bin/sh

grim -g "$(swaymsg -t get_tree | jq -r '.. | select(.pid? and .visible?) | .rect | "\(.x),\(.y) \(.width)x\(.height)"' | $XDG_CONFIG_HOME/sway/scripts/runonce.sh slurp)" - | swappy -f -