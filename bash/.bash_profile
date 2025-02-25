#
# ~/.bash_profile
#

export XDG_CONFIG_HOME=$HOME/.config
export XDG_DOWNLOAD_DIR=$HOME/Downloads
export XDG_STATE_HOME=$HOME/.local/state
export XDG_CURRENT_DESKTOP=sway
export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
export QT_QPA_PLATFORMTHEME=qt6ct
export GTK_USE_PORTAL=1
# export ELECTRON_OZONE_PLATFORM_HINT=auto


if [ -z "$WAYLAND_DISPLAY" ] && [ -n "$XDG_VTNR" ] && [ "$XDG_VTNR" -eq 1 ]; then
	mkdir -p $XDG_STATE_HOME/sway/
	exec sway -d --unsupported-gpu >|"$XDG_STATE_HOME/sway/lastlog" 2>&1
fi

[[ -f ~/.bashrc ]] && . ~/.bashrc
