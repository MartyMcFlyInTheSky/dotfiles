return {
    {
        "nvim-neo-tree/neo-tree.nvim",
        branch = "v3.x",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "MunifTanjim/nui.nvim",
            "nvim-tree/nvim-web-devicons",
        },
        opts = {
            filesystem = {
                -- NOTE: If we activate this opencode will not work correctly since we always switch the cwd and it can't find the instance
                bind_to_cwd = false, -- true creates a 2-way binding between vim's cwd and neo-tree's root
                -- cwd_target = {
                --     sidebar = "global",   -- sidebar is when position = left or right
                --     current = "global" -- . changes global cwd
                -- },
                -- open Neo-tree instead of netrw when you :edit a directory
                hijack_netrw_behavior = "open_default",
                window = {
                    mappings = {
                        ["-"] = "navigate_up",  -- go up one directory (netrw-like)
                    },
                },
            },
        },
        cmd = { 'Neotree' },
        keys = {
            { '<C-w><C-e>', function()
                require("neo-tree.command").execute({
                    source = "filesystem",
                    position = "current", -- take over the current window (fullscreen)
                    reveal = true,        -- reveal current file / cwd
                    toggle = true,
                    action = "show",
                    reveal_force_cwd = true,
                })
            end,
                mode = { 'n' }
            }
        }
    },
    {
        "antosha417/nvim-lsp-file-operations",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-neo-tree/neo-tree.nvim", -- makes sure that this loads after Neo-tree.
        },
        config = function()
            require("lsp-file-operations").setup()
        end,
    },
}
