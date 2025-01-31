return {
    {
        "nvim-telescope/telescope.nvim",
        tag = "0.1.8",
        dependencies = {
            "nvim-lua/plenary.nvim",
            -- "nvim-telescope/telescope-ui-select.nvim",
            "nvim-telescope/telescope-dap.nvim",
            "jvgrootveld/telescope-zoxide",
            "nvim-telescope/telescope-live-grep-args.nvim",
            version = "^1.0.0",
        },
        config = function()
            -- First setup telescope
            local telescope = require("telescope")
            local builtin = require("telescope.builtin")

            local lga_actions = require("telescope-live-grep-args.actions")
            telescope.setup({
                defaults = {
                    mappings = {
                        -- Allow single esc close (https://www.reddit.com/r/neovim/comments/pzxw8h/telescope_quit_on_first_single_esc/)
                        -- i = {
                        -- 	["<esc>"] = function() require("telescope.actions").close() end,
                        -- },
                    },
                },
                extensions = {
                    -- ["ui-select"] = {
                    --     function() require("telescope.themes").get_dropdown({}) end,
                    -- },
                    zoxide = {
                        mappings = {
                            default = {
                                keepinsert = true,
                                action = function(selection)
                                    -- vim.notify("C-f pressed!")
                                    builtin.find_files({ cwd = selection.path })
                                end,
                            },
                        },
                    },
                    live_grep_args = {
                        auto_quoting = true,
                        mappings = {
                            i = {
                                ["<C-k>"] = lga_actions.quote_prompt(),
                                ["<C-i>"] = lga_actions.quote_prompt({ postfix = " --iglob " }),
                                -- freeze the current list and start a fuzzy search in the frozen list
                                ["<C-space>"] = lga_actions.to_fuzzy_refine,
                            },
                        }
                    },
                },
            })
            -- Load the extensions
            -- telescope.load_extension("ui-select")
            telescope.load_extension("zoxide")
            telescope.load_extension("dap")
            telescope.load_extension("live_grep_args")
        end,
        keys = {
            -- Basic telescope commands
            { "<C-s>",      "<cmd>Telescope grep_string<cr>",                                               desc = "Grep string" },
            { "<leader>fo", "<cmd>Telescope oldfiles<cr>",                                                  desc = "List old files" },
            { "<leader>ff", "<cmd>Telescope find_files<cr>",                                                desc = "Find files" },
            { "<leader>fd", "<cmd>Telescope dap configurations<cr>",                                        desc = "Get dap configurations" },
            { "<leader>f?", "<cmd>Telescope help_tags<cr>",                                                 desc = "Explore help tags" },
            { "<leader>fb", "<cmd>Telescope buffers<cr>",                                                   desc = "List open buffer" },

            -- Telescope zoxide extension
            { "<leader>fz", function() require("telescope").extensions.zoxide.list() end,                   desc = "Explore help tags" },

            -- Telescope dap extension
            { "<leader>fd", "<cmd>Telescope dap configurations<cr>",                                        desc = "Show dap configurations" },

            -- Telescope live grep args extension
            { "<leader>fg", function() require('telescope').extensions.live_grep_args.live_grep_args() end, desc = "Live grep" },
        },
        cmd = { "Telescope" },
    },
}
