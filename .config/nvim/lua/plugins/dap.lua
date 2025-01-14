return {
    {
        "mfussenegger/nvim-dap",
        config = function()
            local dap = require("dap") dap.adapters.cppdbg = { id = 'cppdbg',
                type = 'executable',
                command =
                '/home/sbeer/.vscode/extensions/ms-vscode.cpptools-1.22.11-linux-x64/debugAdapters/bin/OpenDebugAD7',
            }
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
        keys = {
            { "<leader>dl",  function() require("dap").step_into() end, { desc = "Debugger step into" } },
            { "<leader>dj", function() require("dap").step_over() end, { desc = "Debugger step over" } },
            { "<leader>dk", function() require("dap").step_out() end, { desc = "Debugger step out" } },
            { "<leader>dc",  function() require("dap").continue() end, { desc = "Debugger continue" } },
            { "<leader>db", function() require("dap").toggle_breakpoint() end, { desc = "Debugger toggle breakpoint"} },
            { "<leader>dd", function() require("dap").set_breakpoint(vim.fn.input('Breakpoint condition: ')) end, { desc = "Debugger set conditional breakpoint"} },
            { "<leader>de", function() require("dap").terminate() end, { desc = "Debugger reset"} },
            { "<leader>dr", function() require("dap").run_last() end, { desc = "Debugger run last"} },
            { "<leader>dt", "<cmd>lua vim.cmd('RustLsp testables')<CR>", { desc = "Debugger testables"} },
            { "<leader>dx", function() require("dapui").close() end, { desc = "Debugger testables"} },
        },
    }
}
