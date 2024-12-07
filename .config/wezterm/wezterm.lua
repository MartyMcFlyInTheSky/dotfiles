local wezterm = require 'wezterm'
local act = wezterm.action
local config = {}
-- Disable wezterm keybindings as we use tmux as our main multiplexer
-- config.disable_default_key_bindings = true

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
    -- Better wezterm find
    {
        key = 'F',
        mods = 'SHIFT|CTRL',
        action = wezterm.action.Search { Regex = '' },
    },
--    {
--        key = 'C',
--        mods = 'CTRL|SHIFT',
--        action = wezterm.action_callback(function(window, pane)
--            local process_name = pane:get_foreground_process_name()
--            wezterm.log_info('process name = ' .. process_name)
--            if process_name == 'nvim' then
--                wezterm.log_info('c + shift + ctrl pressed')
--                wezterm.action.SendString('\033[99;6u')
--            else
--                wezterm.action.CopyTo('Clipboard')
--            end
--        end),
--    },
    -- {
    --     key = "-",
    --     mods = "CTRL",
    --     action = wezterm.action_callback(function(win, pane)
    --         win:perform_action(act.SendString("Hello"), pane)
    --         wezterm.log_info 'Hello from callback!'
    --         wezterm.log_info(
    --             'WindowID:',
    --             win:window_id(),
    --             'PaneID:',
    --             pane:pane_id()
    --         )
    --     end),
    -- },
    -- Ctrl+Shift+C: Send a special escape sequence only if Neovim is in the foreground
    -- {
    --     key = 'C',
    --     mods = 'CTRL|SHIFT',
    --     action = wezterm.action_callback(function(win, pane)
    --         if pane:is_alt_screen_active() then
    --             -- Send the custom escape sequence
    --             win:perform_action(act.SendString("\x1b[99;5u"), pane)
    --         else
    --             -- Otherwise, do nothing or other action if needed
    --         end
    --     end),
    -- },
    {
        key = 'c',
        mods = 'CTRL|SHIFT',
        -- action = act.SendString("Hello World"),
        action = wezterm.action_callback(function(win, pane)
            -- win:perform_action(act.SendString("Hello World"), pane)
            if pane:is_alt_screen_active() then
                -- Send the custom escape sequence
                win:perform_action(act.SendString("\033[99;6u"), pane)
                -- win:perform_action(act.SendString("iHello nvim!\r"), pane)
                wezterm.log_info("alt screen was active")
            else
                -- Otherwise, do nothing or other action if needed
                win:perform_action(act.CopyTo("Clipboard"), pane)
            end
        end),
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


-- Random backgroundcolors
math.randomseed(os.time())

local hue = math.random(0, 360);

-- config.window_background_gradient = {
--         colors = {
--             string.format("hwt123¨(%f,%f%%,0%%)",
--             hue,
--             math.random(25, 40)),
--             string.format("hwb(%f,0%%,%f%%)",
--             hue,
--             math.random(70, 100)),
--         },
--         blend = "Oklab",
--         orientation = {
--             Radial = {
--                 cx = 0.8,
--                 cy = 0.8,
--                 radius = 1.2,
--             }
--         },
--     }


return config

