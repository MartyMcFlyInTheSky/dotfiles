local exception_breakpoints_enabled = false
local exception_filters_by_adapter = {}

local function exception_filters_for_session(session)
    local adapter = session.config.type
    local cached = exception_filters_by_adapter[adapter]
    if cached then
        return cached
    end

    -- Use adapter-reported exception filters when available.
    local filters = {}
    for _, filter in ipairs(session.capabilities.exceptionBreakpointFilters or {}) do
        table.insert(filters, filter.filter)
    end

    exception_filters_by_adapter[adapter] = filters
    return filters
end

local function apply_exception_breakpoints(session)
    if not session then
        return
    end

    local filters = exception_filters_for_session(session)
    if #filters == 0 then
        -- GDB DAP may not advertise exception filters; warn instead of failing silently.
        vim.notify("DAP adapter does not report exception filters", vim.log.levels.WARN)
        return
    end

    if exception_breakpoints_enabled then
        session:set_exception_breakpoints(filters)
    else
        session:set_exception_breakpoints({})
    end
end

local function toggle_dap_exception_breakpoints()
    exception_breakpoints_enabled = not exception_breakpoints_enabled

    local session = require("dap").session()
    if session and session.initialized then
        apply_exception_breakpoints(session)
    end

    if exception_breakpoints_enabled then
        local filter_list = {}
        if session then
            filter_list = exception_filters_for_session(session)
        end
        local detail = #filter_list > 0 and (": " .. table.concat(filter_list, ", ")) or ""
        vim.notify("DAP exception breakpoints enabled" .. detail)
    else
        vim.notify("DAP exception breakpoints disabled")
    end
end

return {
    {
        "rcarriga/nvim-dap-ui",
        dependencies = {
            "nvim-neotest/nvim-nio",
            "mfussenegger/nvim-dap",
        },
        opts = {
            controls = {
                enabled = false,
            },
            layouts = { {
                elements = { {
                    id = "scopes",
                    size = 1,
                } },
                position = "left",
                size = 40
            }, {
                elements = { {
                    id = "repl",
                    size = 1
                } },
                position = "bottom",
                size = 10
            } },
        },
        keys = {
            { "<M-;>", function() require("dapui").toggle() end },
            -- Doesn't work as we already mapped these keys to copy down/up
            -- { "<M-J>", function() require("dapui").eval() end },
            -- { "<M-K>", function() require("dapui").float_element("breakpoints") end },
        },
    },
    {
        "mfussenegger/nvim-dap",
        dependencies = {
            {
                "Joakker/lua-json5",
                build = "./install.sh",
            },
            "theHamsta/nvim-dap-virtual-text",
            "rcarriga/nvim-dap-ui",
            "nvim-neotest/nvim-nio",
        },
        config = function()
            local dap = require("dap")

            -- Setup virtual text
            require("nvim-dap-virtual-text").setup({
                enabled = true,
            })
            dap.set_log_level('TRACE')

            require("dap.loader").setup(dap)

            require("dap.ext.vscode").json_decode = require("json5").parse

            dap.listeners.after.event_initialized["dapui_config"] = function()
                require("dapui").open()
            end

            dap.listeners.after.initialize["exception_breakpoints"] = function(session)
                exception_filters_by_adapter[session.config.type] = nil
                exception_filters_for_session(session)
            end

            dap.listeners.after.configurationDone["exception_breakpoints"] = function(session)
                -- Apply after configuration to avoid adapter overrides during setup.
                if exception_breakpoints_enabled then
                    apply_exception_breakpoints(session)
                end
            end
        end,
        keys = {
            { '<M-l>', function() require('dap').continue() end },
            { '<M-r>', function() require('dap').restart() end },
            { '<M-j>', function() require('dap').step_over() end },
            { '<M-n>', function() require('dap').step_into() end },
            { '<M-p>', function() require('dap').step_out() end },
            { '<M-z>', function() require('dap').terminate() end },
            -- { '<A-h>', function() require('dap').disconnect() end },
            { '<M-k>', function() require('dap').toggle_breakpoint() end },
            { '<M-h>', function() require('dap').clear_breakpoints() end },
            -- { '<Leader>B', function() require('dap').set_breakpoint() end },
            { '<Leader>lp', function() require('dap').set_breakpoint(nil, nil, vim.fn.input('Log point message: ')) end },
            { '<Leader>dc', function() require('dapui').float_element('console') end },
            { '<F23>', function() require('dap').run_last() end },
            { '<A-m>', function() require('dap.ui.widgets').hover() end },
            { '<Leader>dp', function() require('dap.ui.widgets').preview() end },
            { '<A-f>', function() local widgets = require('dap.ui.widgets') widgets.centered_float(widgets.frames) end },
            -- { '<A-s>', function() local widgets = require('dap.ui.widgets') widgets.centered_float(widgets.scopes) end },
            -- { "<F5>", function() dap_helpers.run_current_config() end, { desc = "Debugger continue" } },
            -- { "<F6>", function() dap_helpers.run_current_task() end, { desc = "Run current task" } },
            -- { "<F8>", function() require('dap').continue() end },
            -- { "<F9>", function() require('dap').step_over() end },
            -- { "<F10>", function() require('dap').step_into() end },
            -- { "<F11>", function() require('dap').step_out() end },
            -- { "<F12>", '<cmd>DapTerminate<cr>', { desc = "Debugger reset" } },
            -- { "<F9>", '<cmd>DapToggleBreakpoint<cr>', { desc = "Debugger toggle breakpoint" } },

            { '<A-o>', function() require('dap').up() end, desc = 'Debug: DAP Stack UP' },
            { '<A-i>', function() require('dap').down() end, desc = 'Debug: DAP Stack DOWN' },
            { '<A-u>', toggle_dap_exception_breakpoints, desc = 'Toggle exception breakpoints' },
        },
    },
}
