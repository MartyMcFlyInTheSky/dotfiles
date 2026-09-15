local wezterm = require('wezterm')
local path = require('path')
local act = wezterm.action
local config = {}
local io = require('io')
local os = require('os')

local DOMAINS_JSON_FILE = "/home/sbeer/.local/state/rs/statusfile.lock"

-- if current_domain then
--     wezterm.log_info("WezTerm is running in a mux domain: " .. current_domain:name())
--
-- else
--     wezterm.log_info("WezTerm is not running in a mux domain.")
-- end

-- For mux client panes: Display number of elapsed milliseconds since
-- the most recent response from the multiplexer server.
-- wezterm.on('update-status', function(window, pane)
--   local meta = pane:get_metadata() or {}
--   if meta.is_tardy then
--     local secs = meta.since_last_response_ms / 1000.0
--     window:set_right_status(string.format('tardy: %5.1fs⏳', secs))
--   end
-- end)

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
-- config.ssh_domains = {}
-- config.ssh_domains = wezterm.default_ssh_domains()
--
-- Load configuration from json file (rs lockfile)

---@class SSHDomain
---@field name string
---@field remote_address string
---@field username string
---@field remote_wezterm_path string

---@param filepath string
---@return nil|SSHDomain
local function load_domains_from_json(filepath)
    local file = io.open(filepath, "r")
    if not file then
        wezterm.log_info("Failed to open file: " .. filepath)
        return nil
    end

    local data = file:read("*a")
    file:close()

    local json_domains = wezterm.json_parse(data)
    if not json_domains then
        wezterm.log_info("Failed to parse JSON data from file: " .. filepath)
    end

    -- Bring it to the right form (https://wezterm.org/config/lua/SshDomain.html)
    local domains = {}
    for _, jd in ipairs(json_domains) do
        local d = {
            name = jd.name,
            remote_address = jd.remote_address,
            username = jd.username,
            remote_wezterm_path = path:new(jd.remote_path):join('.local'):join('bin'):join('wezterm'):to_string(),
        }
        table.insert(domains, d)
    end
    return domains
end

wezterm.log_info("Loading remote host configuration from = ", DOMAINS_JSON_FILE)

local domains_cfg = load_domains_from_json(DOMAINS_JSON_FILE)
if domains_cfg ~= nil then
    config.ssh_domains = domains_cfg
    wezterm.log_info("Loaded the following ssh domains: \n", config.ssh_domains)
end

-- wezterm.log_info("domains = ", domains)

-- wezterm.log_info("Loading domain files..:")
-- local other_file = require("ssh_domains")
-- for _, domain in ipairs(other_file.ssh_domains) do
--     table.insert(config.ssh_domains, domain)
-- end
-- wezterm.log_info("Loaded the following ssh domains:")
-- wezterm.log_info(config.ssh_domains)

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
    wezterm.log_info("is_vim called, IS_NVIM =" .. (pane:get_user_vars().IS_NVIM or "nil"))
    return pane:get_user_vars().IS_NVIM == 'true'
end

local function split_pane_conditional(key, direction)
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


local function focus_pane_conditional(key, direction)
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


---@param vimstr string
---@param otherstr string | nil
local function send_string_if_vim_else(vimstr, otherstr)
    return wezterm.action_callback(function(win, pane)
        if is_vim(pane) then
            win:perform_action(wezterm.action.SendString(vimstr), pane)
        elseif otherstr or string.len(otherstr) == 0 then
            win:perform_action(wezterm.action.SendString(otherstr), pane)
        end
    end)
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



local MOD = {
  SHIFT = 0x01,
  ALT   = 0x02,
  CTRL  = 0x04,
  SUPER = 0x08,
}

--- Send a CSI-u (“fixterms”) escape for an ASCII key with modifiers (ESC "[" <codepoint> ";" <modifier_mask+1> "u")
--- @param mods string  Pipe-delimited list of modifiers, case-insensitive, whitespace allowed.
--- @param key  string  Single ASCII character; its byte value (string.byte) becomes the codepoint.
--- @return any         A `wezterm.action.SendString` action that emits the CSI-u bytes when invoked.
function SendFixterm(mods, key)
    -- mods are either SHIFT ALT CTRL, key is in ascii range

    -- Parse mod
    local mask = 0
    for part in mods:gmatch("[^|]+") do
        local tok = part:match("^%s*(.-)%s*$"):upper()  -- trim and uppercase
        local flag = MOD[tok]
        assert(flag, ("unknown modifier: %s"):format(tok))
        mask = mask | flag
    end

    -- Assemble fixterm sequence
    local nr  = key:byte()
    local str = ("\x1b[%d;%du"):format(nr, mask + 1)

    -- Return bind
    return wezterm.action.SendString(str)
end


-- NOTE: This doesn't really work that well since we don't use the environment
-- of the working directory (e.g. activating an python virtualenv will still have pyright
-- complain that the definitions can't be found)
wezterm.on('toggle-nvimsesh', function(window, pane)
    if is_vim(pane) then
        wezterm.log_info("current pane holds vim, sending keys..")
        window:perform_action(act.SendKey({ key='s', mods='CTRL' }), pane)
    else
        local cwd_uri = pane:get_current_working_dir()
        window:perform_action(
            act.SpawnCommandInNewTab {
                args = { 'bash', '-lc', 'nvimsesh'},
                -- Since wezterm somehow resolves symlinks (see https://github.com/wezterm/wezterm/issues/7311)
                -- this is required to keep track of the unresolved paths
                set_environment_variables = {
                    PWD = cwd_uri.file_path,
                },
            },
            pane
        )
    end
end)

wezterm.on('toggle-nvimsesh-last-out', function(window, pane)
    if is_vim(pane) then
        window:perform_action(act.SendKey({ key='e', mods='CTRL' }), pane)
    else
        -- Find all Output zones; the last one is the last command's output
        local zones = pane:get_semantic_zones("Output")
        if not zones or #zones == 0 then
            window:toast_notification('WezTerm', 'No command output zone found', nil, 3000)
            return
        end
        local last = zones[#zones]
        local text = pane:get_text_from_semantic_zone(last)

        -- Create a temporary file to pass to vim
        local name = os.tmpname()
        local f = io.open(name, 'w+')
        f:write(text)
        f:flush()
        f:close()

        -- Open a new window running vim and tell it to open the file
        local cwd_uri = pane:get_current_working_dir()
        window:perform_action(
            act.SpawnCommandInNewTab {
                args = { 'bash', '-lc', 'nvimsesh', name },
                set_environment_variables = {
                    PWD = cwd_uri.file_path,
                },
            },
            pane
        )
    end
end)

wezterm.on('toggle-lazygit', function(window, pane)
    local curr_app = pane:get_foreground_process_name():match("([^/]+)$")
    if curr_app == 'lazygit' then
        window:perform_action(act.SendKey({ key='q' }), pane)
    else
        -- window:set_right_status(process_name or "")
        local cwd_uri = pane:get_current_working_dir()
        window:perform_action(
            act.SpawnCommandInNewTab {
                args = { 'bash', '-lc', '/home/linuxbrew/.linuxbrew/bin/lazygit' },
                set_environment_variables = {
                    PWD = cwd_uri.file_path,
                },
            },
            pane
        )
    end
end)

local function is_bash(pane)
    local proc = pane:get_foreground_process_name() or ""
    return proc:match("bash$") ~= nil
end

--==============================================================================
--  TOGGLE TASK TABS                                                          --
--==============================================================================

local last_tab_by_window = {}

local function basename(path)
  return path:match("([^/]+)$") or path
end

local function tab_has_process(tab, proc)
  for _, pane in ipairs(tab:panes()) do
    local fg = pane:get_foreground_process_name()
    if fg and basename(fg) == proc then
      return true
    end
  end
  return false
end

local function activate_or_spawn_global(window, pane, target_proc, spawn_cmd)
  local mux_window = window:mux_window()
  local tabs = mux_window:tabs()
  local current_tab = mux_window:active_tab()
  local current_index = nil
  local target_index = nil
  for i, tab in ipairs(tabs) do
    if tab:tab_id() == current_tab:tab_id() then
      current_index = i - 1
    end
    if tab_has_process(tab, target_proc) then
      target_index = i - 1
    end
  end
  local window_id = window:window_id()
  local last_index = last_tab_by_window[window_id]
  if target_index ~= nil then
    if current_index == target_index then
      if last_index ~= nil and last_index ~= current_index and tabs[last_index + 1] ~= nil then
        window:perform_action(act.ActivateTab(last_index), pane)
      end
    else
      last_tab_by_window[window_id] = current_index
      window:perform_action(act.ActivateTab(target_index), pane)
    end
    return
  end
  -- Not found: remember current tab, then spawn new tab in current cwd
  last_tab_by_window[window_id] = current_index
  local cwd_uri = pane:get_current_working_dir()
    -- wezterm.log_info("cwd of current pane is " .. (cwd_uri.file_path or "nil"))
  window:perform_action(
    act.SpawnCommandInNewTab({
      cwd = cwd_uri.file_path,
      args = spawn_cmd,
    }),
    pane
  )
end

config.keys = {
    {
      key = "o",
      mods = "SUPER|CTRL",
      action = wezterm.action_callback(function(window, pane)
        activate_or_spawn_global(window, pane, "opencode", { "opencode", "--port" })
      end),
    },
    {
      key = "l",
      mods = "SUPER|CTRL",
      action = wezterm.action_callback(function(window, pane)
        activate_or_spawn_global(window, pane, "lazygit", {
          "/home/linuxbrew/.linuxbrew/bin/lazygit",
        })
      end),
    },
    -- NOTE: No Ctrl-f/b as this clashes with bash bindings
    -- NOTE: Also no Ctrl-Shift-f/b as this clashes with wezterm search
    -- {
    --     key = 'b', mods = 'CTRL|', action = act.ActivateTabRelative(-1)
    -- },
    -- -- NOTE: This clashes with search by default
    -- {
    --     key = 'f', mods = 'CTRL', action = act.ActivateTabRelative(1)
    -- },
    -- Doesn't work since we're using ALT for debugging
    {
        key = 'l', mods = 'ALT|SHIFT', action = wezterm.action.EmitEvent('toggle-lazygit')
    },
    -- {
    --     key = 's', mods = 'CTRL', action = wezterm.action.EmitEvent('toggle-nvimsesh')
    -- },
    {
        key = 's', mods = 'CTRL|SHIFT', action = wezterm.action.EmitEvent('toggle-nvimsesh-last-out')
    },
    {
        -- Override CTRL-Shift-L with a no-op to disable it
        key = "Enter",
        mods = "ALT",
        action = wezterm.action.DisableDefaultAssignment,
    },
    -- Ctrl+s / Ctrl+q (XON/XOFF) are deactivated in bash
    -- {
    --     key = 's',
    --     mods = 'CTRL',
    --     action = wezterm.action_callback(function(window, pane)
    --         pane:move_to_new_window()
    --         -- window:perform_action(act.CloseCurrentTab{ confirm=false }, pane)
    --     end)
    -- },
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
    -- Bash scrolling
    {
        key = 'u',
        mods = 'CTRL|SHIFT',
        action = wezterm.action_callback(function (_, pane)
            if is_bash(pane) then
                return act.ScrollToPrompt(-1)
            else
                return act.SendKey({ key = "u", mods ="CTRL|SHIFT" })
            end
        end)
    },
    {
        key = 'd',
        mods = 'CTRL|SHIFT',
        action = wezterm.action_callback(function (_, pane)
            if is_bash(pane) then
                return act.ScrollToPrompt(-1)
            else
                return act.SendKey({key = "d", mods = "CTRL|SHIFT" })
            end
        end)
    },
    -- -- Direct open
    -- {
    --     key = 'o',
    --     mods = 'ALT',
    --     action = act.SpawnCommandInNewWindow{ label = "Spawn opencode in new window", args = { "opencode" } }
    -- },
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
--    {
--        key = 'h',
--        mods = 'CTRL',
--        action = wezterm.action.ActivateTabRelative(-1)
--    },
--    {
--        key = 'l',
--        mods = 'CTRL',
--        action = wezterm.action.ActivateTabRelative(1)
--    },
   {
       key = 'o',
       mods = 'CTRL|SHIFT',
       action = wezterm.action.ShowDebugOverlay
   },
    -- Spawn mux domain
   -- {
   --     key = 'h',
   --     mods = 'CTRL|SHIFT',
   --     action = wezterm.action.ShowLauncherArgs { flags = 'FUZZY|DOMAINS' },
   -- },
   {
       key = 'i',
       mods = 'CTRL|SHIFT',
       action = wezterm.action.ShowLauncherArgs { flags = 'FUZZY|DOMAINS' },
   },
    -- Split panes
    -- {
    --     key = 'h',
    --     mods = 'CTRL|SHIFT',
    --     action = send_string_if_vim_else('\x1b[1;6h')
    -- },
    -- {
    --     key = 'l',
    --     mods = 'CTRL|SHIFT',
    --     action = send_string_if_vim_else('\x1b[1;6l')
    -- },
    {
        key = 'h',
        mods = 'CTRL|SHIFT',
        action = wezterm.action.SplitPane{
            direction = 'Left',
            size = { Percent = 50 },
        }
    },
    {
        key = 'l',
        mods = 'CTRL|SHIFT',
        action = wezterm.action.SplitPane{
            direction = 'Right',
            size = { Percent = 50 },
        }
    },
    {
        key = 'k',
        mods = 'CTRL|SHIFT',
        action = wezterm.action.SplitPane{
            direction = 'Up',
            size = { Percent = 50 },
        }
    },
    {
        key = 'j',
        mods = 'CTRL|SHIFT',
        action = wezterm.action_callback(function(win, pane)
            win:perform_action({
                SplitPane = {
                    direction = 'Down',
                    size = { Percent = is_vim(pane) and 30 or 50 },
                }
            }, pane)
        end),
    },
    -- Focus panes
    -- {
    --     key = 'h',
    --     mods = 'CTRL',
    --     action = send_string_if_vim_else('\x08')
    -- },
    -- {
    --     key = 'l',
    --     mods = 'CTRL',
    --     action = send_string_if_vim_else('\x0c')
    -- },
    {
        key = 'h',
        mods = 'CTRL',
        action = wezterm.action.ActivatePaneDirection('Left')
    },
    {
        key = 'l',
        mods = 'CTRL',
        action = wezterm.action.ActivatePaneDirection('Right')
    },
    {
        key = 'k',
        mods = 'CTRL',
        action = wezterm.action.ActivatePaneDirection('Up')
    },
    {
        key = 'j',
        mods = 'CTRL',
        action = wezterm.action.ActivatePaneDirection('Down')
    },
    -- Properly forward Ctrl+_ for bash undo
    {
        key = '-',
        mods = 'CTRL',
        action = act.SendKey{ key='_', mods='CTRL' }
    },
    -- Forward copy to copy current readline (needs bash integration)
    {
        key = "c",
        mods = "CTRL|SHIFT",
        action = wezterm.action_callback(function(window, pane)
            local has_selection = window:get_selection_text_for_pane(pane) ~= ""
            if has_selection then
                window:perform_action(act.CopyTo("ClipboardAndPrimarySelection"), pane)
            else
                local cursor = pane:get_cursor_position()
                -- Adapted from: https://wezterm.org/config/lua/pane/get_semantic_zone_at.html
                -- using x-1 here because the cursor may be one cell outside the zone
                local zone = pane:get_semantic_zone_at(cursor.x - 1, cursor.y)
                if zone then
                    local text = pane:get_text_from_semantic_zone(zone)
                    window:copy_to_clipboard(text)
                    window:toast_notification('WezTerm', 'Copied ' .. text .. ' to clipboard!', nil, 3000)
                end
            end
        end)
    },
}

config.mouse_bindings = {
    -- Copy semantic zone (e.g. last command output)
    {
        event = { Down = { streak = 3, button = "Left" }},
        mods = 'NONE',
        action = wezterm.action.SelectTextAtMouseCursor('SemanticZone'),
    }
}

-- Font settings
config.font = wezterm.font_with_fallback {
    { family = "DroidSansMNerdFont", weight = "Regular" },
    'monospace',
    -- 'Phosphor',
    -- 'Koulen',
    -- 'Poiret One',
}
config.font_size = 14.0 -- corresponds to 14 pixels
config.line_height = 1.05
config.cell_width = 1.0
config.freetype_load_target = "HorizontalLcd"   -- alternatives: "Normal", "Light", "Mono", "HorizontalLcd"
config.freetype_render_target = "HorizontalLcd" -- better subpixel smoothing
config.freetype_load_flags = "FORCE_AUTOHINT" -- or "DEFAULT" if you like hinting

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
    input_selector_label_bg = { AnsiColor = 'Black' }, -- (*Since: Nightly Builds Only*)
    input_selector_label_fg = { AnsiColor = 'Blue' }, -- (*Since: Nightly Builds Only*)

    launcher_label_bg = { AnsiColor = 'Black' }, -- (*Since: Nightly Builds Only*)
    launcher_label_fg = { Color = '#ffffff' }, -- (*Since: Nightly Builds Only*)
}

config.enable_tab_bar = false

config.window_padding = { bottom = 0 }

return config
