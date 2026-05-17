#!/bin/sh

torun="$1"

# Check if process is running
if ! pgrep -x "$torun" >/dev/null; then
    exec "$torun"
fi
