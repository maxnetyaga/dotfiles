#
# ~/.bash_profile
#

export GTK_THEME=Adwaita:dark
export XDG_CONFIG_HOME=$HOME/.config
export XDG_DOWNLOAD_DIR=$HOME/Downloads

if [ -z "$WAYLAND_DISPLAY" ] && [ -n "$XDG_VTNR" ] && [ "$XDG_VTNR" -eq 1 ] ; then
	exec sway --unsupported-gpu
fi

[[ -f ~/.bashrc ]] && . ~/.bashrc
