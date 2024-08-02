local wezterm = require 'wezterm'
local act = wezterm.action
local config = {}

-- Disable wezterm keyinbings as we use tmux as our main multiplexer
config.disable_default_key_bindings = true

-- Some we still need
config.keys = {
    {
        key = "c",
        mods = "CTRL|SHIFT",
        action = act.CopyTo "Clipboard",
    },
    {
        key = "v",
        mods = "CTRL|SHIFT",
        action = act.PasteFrom "Clipboard",
    },
    {
        key="-",
        mods="CTRL",
        action=wezterm.action.SendString("cd ..\n"),
    },
}

-- config.color_scheme = 'Dracula'
config.colors = {
    foreground = "#d4d4d4",  -- editor.foreground in VS Code
    background = "#1e1e1e",  -- editor.background in VS Code
    cursor_bg = "#d4d4d4",   -- editorCursor.foreground in VS Code
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
