return {
    {
        "mfussenegger/nvim-dap",
        config = function()
            local dap = require("dap")
            dap.adapters.codelldb = {
                type = "executable",
                command = "codelldb",
            }
            dap.configurations.cpp = {
                {
                    name = 'debug-lldb',
                    type = 'codelldb',
                    request = 'launch',
                    program = function()
                        return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
                    end,
                    cwd = '${workspaceFolder}',
                    stopOnEntry = false,
                    args = {},

                    -- 💀
                    -- if you change `runInTerminal` to true, you might need to change the yama/ptrace_scope setting:
                    --
                    --    echo 0 | sudo tee /proc/sys/kernel/yama/ptrace_scope
                    --
                    -- Otherwise you might get the following error:
                    --
                    --    Error on launch: Failed to attach to the target process
                    --
                    -- But you should be aware of the implications:
                    -- https://www.kernel.org/doc/html/latest/admin-guide/LSM/Yama.html
                    -- runInTerminal = false,
                },
            }
            dap.configurations.c = dap.configurations.cpp
            dap.configurations.rust = {
                {
                    name = "rust target",
                    type = "cppdbg",
                    request = "launch",
                    program = function()
                        -- Get last directory of the cwd
                        local cwd = vim.fn.getcwd()
                        local last_path = cwd:match(".*/(.*)")
                        if last_path == nil then
                            last_path = cwd
                        end
                        local target = cwd .. '/target/debug/' .. last_path
                        return target
                    end,
                    cwd = '${workspaceFolder}',
                    stopOnEntry = true,
                    -- args = {},
                    -- runInTerminal = false,
                },
            }
        end,
        cmd = {}
    },
    {

        "jay-babu/mason-nvim-dap.nvim",
        dependencies = {
            "williamboman/mason.nvim",
            "mfussenegger/nvim-dap",
        },
        opts = {
            ensure_installed = { "codelldb", "debugpy" },
            handlers = {}
        }
    },
    {
        "rcarriga/nvim-dap-ui",
        dependencies = {
            "mfussenegger/nvim-dap",
            "nvim-neotest/nvim-nio",
        },
        config = function()
            local dap = require('dap')

            local dapui = require('dapui')
            dapui.setup()

            dap.listeners.before.attach.dapui_config = function()
                dapui.open()
            end
            dap.listeners.before.launch.dapui_config = function()
                dapui.open()
            end
            dap.listeners.before.event_terminated.dapui_config = function()
                dapui.close()
            end
            dap.listeners.before.event_exited.dapui_config = function()
                dapui.close()
            end
        end,
        -- The reason we specify it like this is because the dap table is not yet available when this luaconfig is loaded
        keys = {
            { "<leader>dl", '<cmd>DapStepInto<cr>',                                                               { desc = "Debugger step into" } },
            { "<leader>dj", '<cmd>DapStepOver<cr>',                                                               { desc = "Debugger step over" } },
            { "<leader>dk", '<cmd>DapStepOut<cr>',                                                                { desc = "Debugger step out" } },
            { "<leader>dc", '<cmd>DapContinue<cr>',                                                               { desc = "Debugger continue" } },
            { "<leader>db", '<cmd>DapToggleBreakpoint<cr>',                                                       { desc = "Debugger toggle breakpoint" } },
            { "<leader>dd", function() require("dap").set_breakpoint(vim.fn.input('Breakpoint condition: ')) end, { desc = "Debugger set conditional breakpoint" } },
            { "<leader>de", '<cmd>DapTermiante<cr>',                                                              { desc = "Debugger reset" } },
            { "<leader>dr", function() require("dap").run_last() end,                                             { desc = "Debugger run last" } },
            { "<leader>dt", "<cmd>RustLsp testables<cr>",                                                         { desc = "Debugger testables" } },
            { "<leader>dx", function() require("dapui").close() end,                                              { desc = "Debugger testables" } },
        },
    }
}
