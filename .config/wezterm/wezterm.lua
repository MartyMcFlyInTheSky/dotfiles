local wezterm = require 'wezterm'
local act = wezterm.action
local config = {}

local mux = wezterm.mux

local current_domain = mux.get_domain()

if current_domain then
    wezterm.log_info("WezTerm is running in a mux domain: " .. current_domain:name())
else
    wezterm.log_info("WezTerm is not running in a mux domain.")
end

-- -- Assuming you have LuaFileSystem (lfs) installed
-- local lfs = require("lfs")
--
-- -- The directory you want to load modules from
-- local directory = "./"
--
-- -- Function to load all Lua modules in a given directory
-- local function load_modules_from_directory(dir)
--     for file in lfs.dir(dir) do
--         -- Skip current and parent directories
--         if file ~= "." and file ~= ".." then
--             -- Get the full file path
--             local fullpath = dir .. "/" .. file
--
--             -- Check if it's a Lua file
--             if fullpath:match("%.lua$") then
--                 -- Load the module (require will search for the module in the Lua path)
--                 local module_name = file:sub(1, -5) -- Remove ".lua" from the filename
--                 require(module_name)
--                 print("Loaded module:", module_name)
--             end
--         end
--     end
-- end
--
-- -- Call the function to load modules
-- load_modules_from_directory(directory)
--
-- Populate ssh_domains from files found in adjacent folder
--
config.ssh_domains = {}

wezterm.log_info("Loading domain files..:")
local other_file = require("ssh_domains")
for _, domain in ipairs(other_file.ssh_domains) do
    table.insert(config.ssh_domains, domain)
end
wezterm.log_info("Loaded the following ssh domains:")
wezterm.log_info(config.ssh_domains)

--
--
-- config.mouse_bindings = {
--     {
--         event = { Down = { streak = 4, button = 'Left' } },
--         action = wezterm.action.SelectTextAtMouseCursor 'SemanticZone',
--         mods = 'NONE',
--     },
-- }
-- I need to come back to this, but for now deactivate the automatic reassignement
-- of the socket (https://wezfurlong.org/wezterm/config/lua/config/mux_enable_ssh_agent.html)
-- config.mux_enable_ssh_agent = false


-- Display mux daemon delay in status bar
-- wezterm.on('update-status', function(window, pane)
--   local meta = pane:get_metadata() or {}
--   if meta.is_tardy then
--     local secs = meta.since_last_response_ms / 1000.0
--     window:set_right_status(string.format('tardy: %5.1fs⏳', secs))
--   end
-- end)

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


wezterm.on('format-tab-title', function(tab, tabs, panes, cfg, hover, max_width)
  if string.sub(tab.active_pane.domain_name, 1, 7) == "SSHMUX:" then
    local title = tab.active_pane.domain_name:gsub("SSHMUX:", "")
    wezterm.log_info("Tab title: " .. title)
    local color = "#883334"
    if tab.is_active then
        color = "#E4080A"
    end
    return {
      { Background = { Color = color } },
      { Text = ' ' .. title .. ' ' },
    }
  else
    local title = tab.active_pane.title
    local color = "#1D1F21"
    return {
      { Background = { Color = color } },
      { Text = ' ' .. title .. '*' },
    }
  end
end)

config.keys = {
    {
        -- Override CTRL-Shift-L with a no-op to disable it
        key = "Enter",
        mods = "ALT",
        action = wezterm.action.DisableDefaultAssignment,
    },
    -- Ctrl+s / Ctrl+q (XON/XOFF) are deactivated in bash
    { key = 'q',
        mods = 'CTRL',
        action = wezterm.action.CloseCurrentTab { confirm=true },
    },
    {
        key = 's',
        mods = 'CTRL',
        action = wezterm.action_callback(function(window, pane)
            pane:move_to_new_window()
            -- window:perform_action(act.CloseCurrentTab{ confirm=false }, pane)
        end)
    },
    -- Close (stuck) ssh session (https://apple.stackexchange.com/questions/35524/what-can-i-do-when-my-ssh-session-is-stuck)
    {
        key = 'k',
        mods = 'LEADER',
        action = act.SendString('\r~.'),
    },
    {
        key = 'r',
        mods = 'LEADER',
        action = wezterm.action_callback(function(window, pane)
            local foreground_app_path = pane:get_foreground_process_name()
            local foreground_app = foreground_app_path:match("([^/]+)$")
            if foreground_app == 'bash' then
                window:perform_action(
                    act.SendString('\u{85}'),
                    pane
                )
            end
        end)
    },
    -- Prompt for a name to use for a new workspace and switch to it.
    -- {
    --     key = 'W',
    --     mods = 'CTRL|SHIFT',
    --     action = act.PromptInputLine {
    --         description = wezterm.format {
    --             { Attribute = { Intensity = 'Bold' } },
    --             { Foreground = { AnsiColor = 'Fuchsia' } },
    --             { Text = 'Enter name for new workspace' },
    --         },
    --         action = wezterm.action_callback(function(window, pane, line)
    --             -- line will be `nil` if they hit escape without entering anything
    --             -- An empty string if they just hit enter
    --             -- Or the actual line of text they wrote
    --             if line then
    --                 window:perform_action(
    --                     act.SwitchToWorkspace {
    --                         name = line,
    --                     },
    --                     pane
    --                 )
    --             end
    --         end),
    --     },
    -- },
    -- Prev/next tab
    {
        key = 'h',
        mods = 'CTRL',
        action = wezterm.action.ActivateTabRelative(-1)
    },
    {
        key = 'l',
        mods = 'CTRL',
        action = wezterm.action.ActivateTabRelative(1)
    },
    {
        key = 'o',
        mods = 'CTRL|SHIFT',
        action = wezterm.action.ShowDebugOverlay
    },
    -- Spawn mux domain
    {
        key = 'h',
        mods = 'CTRL|SHIFT',
        action = wezterm.action.ShowLauncherArgs { flags = 'FUZZY|DOMAINS' },
    },
    {
        key = 'l',
        mods = 'CTRL|SHIFT',
        action = wezterm.action.ShowLauncherArgs { flags = 'FUZZY|DOMAINS' },
    },
    -- Split panes
    split_pane('k', 'Up'),
    split_pane('j', 'Down'),
    -- Focus panes
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
