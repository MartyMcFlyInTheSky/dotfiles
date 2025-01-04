return {
    {
        "mfussenegger/nvim-dap",
        config = function()
            local dap = require("dap")
            dap.adapters.cppdbg = {
                id = 'cppdbg',
                type = 'executable',
                command =
                '/home/sbeer/.vscode/extensions/ms-vscode.cpptools-1.22.11-linux-x64/debugAdapters/bin/OpenDebugAD7',
            }
            dap.configurations.rust = {
                {
                    name = "Launch file",
                    type = "cppdbg",
                    request = "launch",
                    program = function()
                        return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
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
                dap.listeners.before.event_exited.dapui_config = function()
                end
                dapui.close()
            end
        end,
        keys = {
            { "<leader>dt", function() require("dap").toggle_breakpoint() end, {} },
            { "<leader>dc", function() require("dap").continue() end,          {} },
            { "<leader>dd", function() require("dapui").close() end,          {} },
        },
    }
}
