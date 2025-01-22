#!/usr/bin/env bash

directories=(
    ~/dev/
    ~/test/sbeer/
)

existing_directories=()

for dir in "${directories[@]}"; do
    if [[ -d $dir ]]; then
        existing_directories+=("$dir")
    fi
done

if [[ ${#existing_directories[@]} -eq 0 ]]; then
    echo "No project directories found!"
    exit 1
fi

if [[ $# -eq 1 ]]; then
    dir=$1
else
    dir=$(find "${existing_directories[@]}" -mindepth 1 -maxdepth 1 -type d | fzf)
fi

if [[ -z $dir ]]; then
    exit 0
fi

session_name=$(basename "$dir" | tr . _)
tmux_running=$(pgrep tmux)

# Create session and attach to it if tmux is not yet running
if [[ -z $TMUX ]] && [[ -z $tmux_running ]]; then
    tmux new-session -s $session_name -c $dir
    exit 0
fi

# If tmux is running and session is not active, create new detached session
if ! tmux has-session -t=$session_name 2> /dev/null; then
    tmux new-session -ds $session_name -c $dir
fi

# Attach to session
if [[ -z $TMUX ]]; then
    tmux attach -t $session_name
else
    tmux switch-client -t $session_name
fi
