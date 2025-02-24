#!/bin/sh

toolwait=$XDG_CONFIG_HOME/sway/scripts/toolwait

swaymsg "workspace number 1"
$toolwait --nocheck firefox --waitfor firefox

swaymsg "workspace number 2"
$toolwait --nocheck alacritty --waitfor alacritty

swaymsg "workspace number 3"
$toolwait --nocheck code --waitfor code

swaymsg "workspace number 4"
$toolwait --nocheck nautilus --waitfor nautilus

swaymsg "workspace number 5"
$toolwait --nocheck spotify --waitfor spotify

swaymsg "workspace number 6"
$toolwait --nocheck telegram-desktop --waitfor telegram-desktop

swaymsg "workspace number 7"
$toolwait --nocheck thunderbird --waitfor thunderbird

swaymsg "workspace number 8"

# whould be cleared on config reload
swaymsg "focus_on_window_activation focus"

# setting keyboard layout
swaymsg 'input * xkb_layout "us,ru"'
