#!/bin/sh

toolwait=$XDG_CONFIG_HOME/sway/scripts/toolwait
run_telegram=$XDG_CONFIG_HOME/sway/scripts/run_telegram.sh
run_spotify=$XDG_CONFIG_HOME/sway/scripts/run_spotify.sh

swaymsg 'input * events disabled'

swaymsg "workspace number 1"
$toolwait --nocheck chromium --waitfor chromium

swaymsg "workspace number 2"
$toolwait --nocheck alacritty --waitfor alacritty

swaymsg "workspace number 3"
$toolwait --nocheck code --waitfor code

swaymsg "workspace number 4"
$toolwait --nocheck nautilus --waitfor nautilus

swaymsg "workspace number 5"
$toolwait --nocheck $run_telegram --waitfor org.telegram.desktop

swaymsg "workspace number 6"
$toolwait --nocheck $run_spotify --waitfor chrome-pjibgclleladliembfgfagdaldikeohf-Defaul
swaymsg "workspace number 7"
$toolwait --nocheck thunderbird --waitfor thunderbird

swaymsg "workspace number 8"

# whould be cleared on config reload
swaymsg "focus_on_window_activation focus"

# setting keyboard layout
swaymsg 'input * xkb_layout "us,ru"'
echo -n "us,ru" >| $XDG_CONFIG_HOME/rofi/scripts/lang

swaymsg "[app_id="org.telegram.desktop"]" floating disable

# can cause problems
swaymsg 'input * events enabled'

exec localsend --hidden
