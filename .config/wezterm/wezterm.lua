local wezterm = require 'wezterm'
local act = wezterm.action
local config = {}


config.keys = {
  -- {
  --   key = 'd',
  --   mods = 'CTRL',
  --   action = act.CloseCurrentPane { confirm = true },
  -- },
  {
    key = 'r',
    mods = 'CMD|SHIFT',
    action = act.ReloadConfiguration,
  },
  -- This will create a new split and run your default program inside it
  {
    key = '"',
    mods = 'CTRL|SHIFT|ALT',
    action = act.SplitVertical { domain = 'CurrentPaneDomain' },
  },
  {
    key = '%',
    mods = 'CTRL|SHIFT|ALT',
    action = act.SplitHorizontal { domain = 'CurrentPaneDomain' },
  },
  -- {
  --   key = 'h',
  --   mods = 'CTRL',
  --   action = act.ActivatePaneDirection 'Left',
  -- },
  -- {
  --   key = 'l',
  --   mods = 'CTRL',
  --   action = act.ActivatePaneDirection 'Right',
  -- },
  -- {
	 --  key = 'b',
	 --  mods = 'CTRL',
	 --  action = wezterm.action {
		--   SendKey = {
		-- 	  key = 'l',
		-- 	  mods = 'CTRL'
		--   }
	 --  }
  -- }
  -- {
  --   key = 'k',
  --   mods = 'CTRL',
  --   action = act.ActivatePaneDirection 'Up',
  -- },
  -- {
  --   key = 'j',
  --   mods = 'CTRL',
  --   action = act.ActivatePaneDirection 'Down',
  -- },
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
