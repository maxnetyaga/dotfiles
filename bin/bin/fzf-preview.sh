#!/usr/bin/env bash
set -euo pipefail

file="$1"

if [[ -z "${file:-}" || ! -f "$file" ]]; then
    kitten icat --clear --transfer-mode=memory --stdin=no
    exit 0
fi

output=$(bat --style=plain --color=always --pager=never "$file" 2>&1) || true

if grep -q -E "\[bat warning\]" <<< "$output"; then
    kitten icat --clear --transfer-mode=memory --stdin=no --place=${FZF_PREVIEW_COLUMNS}x${FZF_PREVIEW_LINES}@0x0 "$file"
else
    kitten icat --clear --transfer-mode=memory --stdin=no
    echo "$output"
fi
