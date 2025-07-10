#!/bin/bash

cd "$(dirname "$(realpath "$0")")" || exit 1

git add -A
git commit -m "Daily commit: $(date '+%Y-%m-%d %H:%M:%S')" || exit 0
git push origin main
