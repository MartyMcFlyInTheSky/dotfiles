#!/bin/bash
# Launch WezTerm in the cwd of the focused pane/window.
# Falls back to $HOME if cwd cannot be determined.

focused_window=$(xdotool getactivewindow 2>/dev/null)
focused_pid=$(xdotool getwindowpid "$focused_window" 2>/dev/null)
cwd=""

# WezTerm owns all pane processes from one GUI PID, so process-tree order cannot
# identify the focused pane. Ask WezTerm for the focused pane and spawn directly.
if [ -n "$focused_window" ] &&
    [ "$(ps -p "$focused_pid" -o comm= 2>/dev/null)" = "wezterm-gui" ] &&
    command -v jq >/dev/null 2>&1; then
    focused_pane_id=$(wezterm cli list-clients --format json 2>/dev/null |
        jq -r --arg pid "$focused_pid" \
            'map(select((.pid | tostring) == $pid)) | .[0].focused_pane_id // empty')

    if [ -n "$focused_pane_id" ]; then
        cwd_uri=$(wezterm cli list --format json 2>/dev/null |
            jq -r --argjson pane_id "$focused_pane_id" \
                'map(select(.pane_id == $pane_id)) | .[0].cwd // empty')

        if [[ "$cwd_uri" == file://* ]]; then
            cwd_path=${cwd_uri#file://}
            if [[ "$cwd_path" == /* ]]; then
                cwd="$cwd_path"
            else
                # Drop URI hostname; cwd is always on the local machine here.
                cwd="/${cwd_path#*/}"
            fi
        fi
    fi

    if [ -d "$cwd" ]; then
        exec wezterm start --cwd "$cwd"
    fi
fi

# Retain support for non-WezTerm focused terminal windows.
if [ -n "$focused_pid" ]; then
    leaf_pid=$(pstree -p "$focused_pid" 2>/dev/null |
        grep -oP '\(\K[0-9]+' | tail -1)
    if [ -n "$leaf_pid" ]; then
        cwd=$(readlink "/proc/$leaf_pid/cwd" 2>/dev/null)
    fi
fi

if [ ! -d "$cwd" ]; then
    cwd="$HOME"
fi

exec wezterm start --cwd "$cwd"
