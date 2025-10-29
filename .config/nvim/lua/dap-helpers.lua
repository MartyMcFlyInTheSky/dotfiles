
local M = {}

local dap_dir

function M.setup(opts)
    dap_dir = opts.dap_path or ""

    -- Setup package path
    package.path = dap_dir .. "/?.lua;" .. dap_dir .. "/?/init.lua;" .. package.path
end

function M.get_adapters()
    -- Use isdirectory(), not exists()
    if vim.fn.isdirectory(dap_dir) == 0 then
        return {}
    end

    -- Get all modules from the dap directory
    local uv = vim.loop
    local modules, iter = {}, uv.fs_scandir(dap_dir)
    while true do
        local name, type = uv.fs_scandir_next(iter)
        if not name then break end
        if type == "file" then
            local mod = name:match("^(.*)%.lua$")
            if mod then table.insert(modules, mod) end
        end
    end

    -- Create a table that contains all dap configurations
    local dap_adapter_configs = {}
    for _, m in ipairs(modules) do
        local ok, module = pcall(require, m)
        if ok and type(module) == "table" then
            dap_adapter_configs[m] = module
        end
    end

    return dap_adapter_configs
end



-- Debug config

local curr_debug = {}

function M.set_debug_config(debug_config)
    vim.print("Hello from set debug config!")
    curr_debug = debug_config or {}
end

function M.get_debug_config()
    vim.print("Hello from get debug config!")
    return curr_debug
end

function M.run_current_config()
    -- Check if global variable is set in telescope
    require('dap').run(curr_debug)
end

-- Tasks

return M
