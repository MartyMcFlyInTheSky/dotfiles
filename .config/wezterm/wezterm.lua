local wezterm = require 'wezterm'
local act = wezterm.action
local config = {}

-- I need to come back to this, but for now deactivate the automatic reassignement
-- of the socket (https://wezfurlong.org/wezterm/config/lua/config/mux_enable_ssh_agent.html)
-- config.mux_enable_ssh_agent = false

-- Some we still need
config.leader = {
    key = ' ',
    mods = 'CTRL',
}

config.keys = {
    -- Close (stuck) ssh session (https://apple.stackexchange.com/questions/35524/what-can-i-do-when-my-ssh-session-is-stuck)
    {
        key = 'k',
        mods = 'LEADER',
        action = act.SendString('\r~.'),
    },
}

config.font = wezterm.font_with_fallback {
    '0xProto Nerd Font Mono',
    'Phosphor',
    'Koulen',
    'Poiret One',
}

-- config.color_scheme = 'Dracula'
config.colors = {
    foreground = "#B3BBE5", -- periwinkle
    background = "#1A170E", -- smoky_black
    cursor_bg = "#d4d4d4",  -- editorCursor.foreground in VS Code
    cursor_border = "#d4d4d4",
    cursor_fg = "#1e1e1e",
    selection_bg = "#264f78", -- editor.selectionBackground in VS Code
    selection_fg = "#d4d4d4",

    ansi = {
        "#000000", -- black
        "#cd3131", -- red
        "#0dbc79", -- green
        "#e5e510", -- yellow
        "#2472c8", -- blue
        "#bc3fbc", -- magenta
        "#11a8cd", -- cyan
        "#e5e5e5", -- white
    },
    brights = {
        "#666666", -- bright black
        "#f14c4c", -- bright red
        "#23d18b", -- bright green
        "#f5f543", -- bright yellow
        "#3b8eea", -- bright blue
        "#d670d6", -- bright magenta
        "#29b8db", -- bright cyan
        "#e5e5e5", -- bright white
    },
}

return config
