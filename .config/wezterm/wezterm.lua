local wezterm = require 'wezterm'
local act = wezterm.action
local config = {}

-- I need to come back to this, but for now deactivate the automatic reassignement
-- of the socket (https://wezfurlong.org/wezterm/config/lua/config/mux_enable_ssh_agent.html)
-- config.mux_enable_ssh_agent = false

local random_string = function(length)
    -- Open /dev/urandom to read random bytes
    local random_file = io.open("/dev/urandom", "rb")
    if not random_file then
        wezterm.log_info("Failed to open /dev/urandom")
    end

    -- Read random bytes
    local random_bytes = random_file:read(length)
    random_file:close()

    -- Convert bytes to a hexadecimal string
    local random_name = ""
    for i = 1, #random_bytes do
        random_name = random_name .. string.format("%02x", random_bytes:byte(i))
    end

    wezterm.log_info("Generated random name: " .. random_name:sub(1, length))
    -- Truncate to the desired length
    return random_name:sub(1, length)
end

config.set_environment_variables = {
    NVIM_RNDPIPE = random_string(10),
}

-- Some we still need
config.leader = {
    key = ' ',
    mods = 'CTRL',
}

local function is_vim(pane)
    -- this is set by the smart-splits plugin, and unset on ExitPre in Neovim
    return pane:get_user_vars().IS_NVIM == 'true'
end

local function split_pane(key, direction)
    return {
        key = key,
        mods = 'CTRL|SHIFT',
        action = wezterm.action_callback(function(win, pane)
            if is_vim(pane) and direction == 'Down' then
                win:perform_action({
                    SplitPane = {
                        direction = direction,
                        size = { Percent = 30 },
                    }
                }, pane)
            else
                win:perform_action({
                    SplitPane = {
                        direction = direction,
                        size = { Percent = 50 },
                    }
                }, pane)
            end
        end),
    }
end


local function focus_pane(key, direction)
    return {
        key = key,
        mods = 'CTRL',
        action = wezterm.action_callback(function(win, pane)
            if is_vim(pane) then
                win:perform_action({
                    SendKey = { key = key, mods = 'CTRL' },
                }, pane)
            else
                win:perform_action({
                    ActivatePaneDirection = direction,
                }, pane)
            end
        end),
    }
end


config.keys = {
    -- Close (stuck) ssh session (https://apple.stackexchange.com/questions/35524/what-can-i-do-when-my-ssh-session-is-stuck)
    {
        key = 'k',
        mods = 'LEADER',
        action = act.SendString('\r~.'),
    },
    -- Prompt for a name to use for a new workspace and switch to it.
    {
        key = 'W',
        mods = 'CTRL|SHIFT',
        action = act.PromptInputLine {
            description = wezterm.format {
                { Attribute = { Intensity = 'Bold' } },
                { Foreground = { AnsiColor = 'Fuchsia' } },
                { Text = 'Enter name for new workspace' },
            },
            action = wezterm.action_callback(function(window, pane, line)
                -- line will be `nil` if they hit escape without entering anything
                -- An empty string if they just hit enter
                -- Or the actual line of text they wrote
                if line then
                    window:perform_action(
                        act.SwitchToWorkspace {
                            name = line,
                        },
                        pane
                    )
                end
            end),
        },
    },
    -- Split panes
    split_pane('h', 'Left'),
    split_pane('l', 'Right'),
    split_pane('k', 'Up'),
    split_pane('j', 'Down'),
    -- Focus panes
    focus_pane('h', 'Left'),
    focus_pane('l', 'Right'),
    focus_pane('j', 'Down'),
    focus_pane('k', 'Up'),
}

config.font = wezterm.font_with_fallback {
    'DroidSansMNerdFont',
    'monospace',
    -- 'Phosphor',
    -- 'Koulen',
    -- 'Poiret One',
}
config.font_size = 12.0

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
