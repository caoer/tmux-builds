#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${PREFIX:-}" ]]; then
    echo "Error: PREFIX must be set"
    exit 1
fi

file "$PREFIX/bin/tmux"

if [[ "$(uname)" == "Darwin" ]]; then
    otool -L "$PREFIX/bin/tmux"
else
    ldd "$PREFIX/bin/tmux" || true
fi

echo "Starting a test tmux session..."
"$PREFIX/bin/tmux" new-session -d -s test

echo "Listing tmux sessions..."
"$PREFIX/bin/tmux" ls

echo "Killing test tmux session..."
"$PREFIX/bin/tmux" kill-session -t test
