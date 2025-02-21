#!/bin/sh

toolwait=$XDG_CONFIG_HOME/sway/scripts/toolwait

swaymsg "workspace number 1"
$toolwait --nocheck firefox --waitfor firefox

swaymsg "workspace number 2"
$toolwait --nocheck alacritty --waitfor alacritty

swaymsg "workspace number 3"
$toolwait --nocheck code --waitfor code

swaymsg "workspace number 4"
$toolwait --nocheck nemo --waitfor nemo

swaymsg "workspace number 5"
$toolwait --nocheck spotify --waitfor spotify

swaymsg "workspace number 6"
