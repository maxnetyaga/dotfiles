#!/bin/bash

GVFS_PATH="$XDG_RUNTIME_DIR/gvfs"

# Ensure the directory exists
mkdir -p "$GVFS_PATH"

# Try entering the mount point
if ! cd "$GVFS_PATH" 2>/dev/null; then
    echo "GVFS mount is broken, repairing…"

    # Attempt to unmount
    fusermount -u "$GVFS_PATH" 2>/dev/null

    # Restart gvfs FUSE daemon
    /usr/lib/gvfsd-fuse "$GVFS_PATH" &>/dev/null &

    echo "Restored gvfsd-fuse on $GVFS_PATH"
else
    echo "GVFS mount OK"
fi

