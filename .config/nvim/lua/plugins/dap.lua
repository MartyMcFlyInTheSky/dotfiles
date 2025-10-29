
local dap_helpers = require('dap-helpers')

return {
    {
        "mfussenegger/nvim-dap",
        dependencies = {
            {
                'Joakker/lua-json5',
                build = './install.sh',
            },
        },
        config = function()
            local dap = require('dap')
            vim.tbl_deep_extend("force", dap.adapters or {}, dap_helpers.get_adapters())

            -- vim.print("dap was loaded")

            -- Use liberal json parser to mimic what vscode is doing
            -- require('dap.ext.vscode').json_decode = require('json5').parse
            -- This is a deprecated function but the telescope-dap extension counts on us
            -- populating the configurations instead of using the 'dap.launch.json' provider
            -- require('dap.ext.vscode').load_launchjs()
        end,
        keys = {
            -- { "<F5>", function() dap_helpers.run_current_config() end, { desc = "Debugger continue" } },
            -- { "<F6>", function() dap_helpers.run_current_task() end, { desc = "Run current task" } },
            { "<F10>", '<cmd>DapStepOver<cr>', { desc = "Debugger step over" } },
            { "<F11>", '<cmd>DapStepInto<cr>', { desc = "Debugger step into" } },
            -- Shift+<F11>
            { "<F23>", '<cmd>DapStepOut<cr>', { desc = "Debugger step out" } },
            -- Shift+<F5>
            { "<F17>", '<cmd>DapTerminate<cr>', { desc = "Debugger reset" } },
            { "<F9>", '<cmd>DapToggleBreakpoint<cr>', { desc = "Debugger toggle breakpoint" } },
        },
        -- TODO: Remove this line as we don't want unnecessary overhead when we're not interested in debugging
        lazy = false,
    },
}


--          config = function()
--  
--              vim.api.nvim_set_hl(0, 'YellowCursor', { fg='#FFCC00' })
--              vim.api.nvim_set_hl(0, 'YellowBack', { bg="#4C4C19" })
--  
--              -- vim.fn.sign_define('DapBreakpoint', { text='●', texthl='Yellow1234', linehl='', numhl=''})
--              -- vim.fn.sign_define('DapBreakpointCondition', { text='●', texthl='HelloWorld', linehl='HelloWorld2', numhl='HelloWorld3'})
--              -- vim.fn.sign_define('DapLogPoint', { text='●', texthl='HelloWorld', linehl='HelloWorld2', numhl='HelloWorld3'})
--              vim.fn.sign_define('DapStopped', { text='', texthl='YellowCursor', linehl='YellowBack', numhl=''})
--              -- vim.fn.sign_define('DapBreakpointRejected', { text='○', texthl='HelloWorld', linehl='HelloWorld2', numhl='HelloWorld3'})
--              -- vim.fn.sign_define('DapBreakpoint', {text='●○', texthl='', linehl='HelloWorld', numhl=''})
--  
--              local dap = require("dap")
--              -- dap.adapters.codelldb = {
--              --     type = "executable",
--              --     command = "codelldb",
--              -- }
--              -- dap.adapters.codelldb = {
--              --     type = 'pipe',
--              --     pipe = '',
--              --     command = 
--              --     args = 
--              -- }
--              dap.configurations.cpp = {
--                  {
--                      name = 'debug-lldb',
--                      type = 'codelldb',
--                      request = 'launch',
--                      program = function()
--                          return vim.fn.input('Path to executable 2: ', vim.fn.getcwd() .. '/', 'file')
--                      end,
--                      cwd = '${workspaceFolder}',
--                      stopOnEntry = false,
--                      args = {},
--  
--                      -- 💀
--                      -- if you change `runInTerminal` to true, you might need to change the yama/ptrace_scope setting:
--                      --
--                      --    echo 0 | sudo tee /proc/sys/kernel/yama/ptrace_scope
--                      --
--                      -- Otherwise you might get the following error:
--                      --
--                      --    Error on launch: Failed to attach to the target process
--                      --
--                      -- But you should be aware of the implications:
--                      -- https://www.kernel.org/doc/html/latest/admin-guide/LSM/Yama.html
--                      -- runInTerminal = false,
--                  },
--              }
--              dap.configurations.c = dap.configurations.cpp
--              dap.configurations.rust = {
--                  {
--                      name = "rust target",
--                      type = "codelldb",
--                      request = "launch",
--                      program = function()
--                          -- Get last directory of the cwd
--                          local cwd = vim.fn.getcwd()
--                          local last_path = cwd:match(".*/(.*)")
--                          if last_path == nil then
--                              last_path = cwd
--                          end
--                          local target = cwd .. '/target/debug/' .. last_path
--                          return target
--                      end,
--                      cwd = '${workspaceFolder}',
--                      stopOnEntry = true,
--                      -- args = {},
--                      -- runInTerminal = false,
--                  },
--              }
--          end,
--          cmd = {}
--      },
--      {
--  
--          "jay-babu/mason-nvim-dap.nvim",
--          dependencies = {
--              "williamboman/mason.nvim",
--              "mfussenegger/nvim-dap",
--          },
--          opts = {
--              ensure_installed = { "codelldb", "debugpy" },
--              handlers = {}
--          }
--      },
--      {
--          "rcarriga/nvim-dap-ui",
--          dependencies = {
--              "mfussenegger/nvim-dap",
--              "nvim-neotest/nvim-nio",
--          },
--          config = function()
--              local dap = require('dap')
--  
--              local dapui = require('dapui')
--              dapui.setup()
--  
--              dap.listeners.before.attach.dapui_config = function()
--                  dapui.open()
--              end
--              dap.listeners.before.launch.dapui_config = function()
--                  dapui.open()
--              end
--              dap.listeners.before.event_terminated.dapui_config = function()
--                  dapui.close()
--              end
--              dap.listeners.before.event_exited.dapui_config = function()
--                  dapui.close()
--              end
--          end,
--          -- The reason we specify it like this is because the dap table is not yet available when this luaconfig is loaded
--          keys = {
--              { "<leader>dh", function() require("dap").step_back() end,                                          { desc = "Debugger step over" } },
--              { "<leader>dj", '<cmd>DapStepInto<cr>',                                                               { desc = "Debugger step into" } },
--              { "<leader>dk", '<cmd>DapStepOut<cr>',                                                                { desc = "Debugger step out" } },
--              { "<leader>dl", '<cmd>DapStepOver<cr>',                                                               { desc = "Debugger step over" } },
--              { "<leader>dc", '<cmd>DapContinue<cr>',                                                               { desc = "Debugger continue" } },
--              { "<leader>db", '<cmd>DapToggleBreakpoint<cr>',                                                       { desc = "Debugger toggle breakpoint" } },
--              { "<leader>dd", function() require("dap").set_breakpoint(vim.fn.input('Breakpoint condition: ')) end, { desc = "Debugger set conditional breakpoint" } },
--              { "<leader>de", '<cmd>DapTerminate<cr>',                                                              { desc = "Debugger reset" } },
--              { "<leader>dr", function() require("dap").run_last() end,                                             { desc = "Debugger run last" } },
--              { "<leader>dt", "<cmd>RustLsp testables<cr>",                                                         { desc = "Debugger testables" } },
--              { "<leader>dx", function() require("dapui").close() end,                                              { desc = "Debugger testables" } },
--          },
--      }
