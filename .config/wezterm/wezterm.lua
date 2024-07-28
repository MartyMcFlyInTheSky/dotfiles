local wezterm = require 'wezterm'
local act = wezterm.action
local config = {}


config.leader = { 
    key = 'a', 
    mods = 'CTRL' 
}


-- Helper function to change pane or create a new one
local function change_or_create_pane(direction)
  return function(window, pane)
    local result = pane:send_pane_select_by_direction(direction)
    if not result then
      -- If changing pane fails, create a new one in the specified direction
      if direction == "Left" then
        window:perform_action(wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }), pane)
      elseif direction == "Right" then
        window:perform_action(wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }), pane)
      elseif direction == "Up" then
        window:perform_action(wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }), pane)
      elseif direction == "Down" then
        window:perform_action(wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }), pane)
      end
    end
  end
end

-- Configure keybindings
local config = {
}

config.keys = {
    {
        key = 'l',
        mods = 'CTRL|SHIFT',
        action = wezterm.action.DisableDefaultAssignment,
    }
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
