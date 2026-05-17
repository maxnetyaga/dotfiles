#!/usr/bin/env bash
(
    cd $(dirname "${BASH_SOURCE[0]}")
    chattr -R -i /usr/share/X11/xkb/symbols/
    chattr -R -i /usr/share/X11/xkb/rules/evdev.xml
    cp us /usr/share/X11/xkb/symbols/us
    cp ru /usr/share/X11/xkb/symbols/ru
    cp evdev.xml /usr/share/X11/xkb/rules/evdev.xml
    chattr -R +i /usr/share/X11/xkb/symbols/
    chattr -R +i /usr/share/X11/xkb/rules/evdev.xml
)
