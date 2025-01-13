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
                dap.listeners.before.event_exited.dapui_config = function()
                end
                dapui.close()
            end
        end,
        keys = {
            { "<leader>b", function() require("dap").toggle_breakpoint() end, {} },
            { "<leader>dc", function() require("dap").continue() end,          {} },
            { "<leader>dd", function() require("dapui").close() end,          {} },
        },
    }
}
