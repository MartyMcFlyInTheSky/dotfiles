return {
    {
        'lewis6991/gitsigns.nvim',
        config = function()
            local home = vim.fn.expand("~")
            local opts = {
                worktrees = {
                    {
                        toplevel = home,
                        gitdir = home .. "/.myconfig",
                    }
                }
            }
            require("gitsigns").setup(opts)

            -- vim.keymap.set({'o', 'x'}, 'ih', '<CMD>Gitsigns select_hunk<CR>')
            -- vim.keymap.set('n', '[c', '<CMD>Gitsigns prev_hunk<CR>')
            -- vim.keymap.set('n', ']c', '<CMD>Gitsigns next_hunk<CR>')
        end,
        keys = {
            -- { '<leader>hs', function() require('gitsigns').stage_hunk() end },
            -- { '<leader>hr', function() require('gitsigns').reset_hunk() end },
            { '[h', function()
                if vim.wo.diff then
                    vim.cmd.normal({'[c', bang = true})
                else
                    require('gitsigns').nav_hunk('prev')
                end
            end
            },
            { ']h', function()
                if vim.wo.diff then
                    vim.cmd.normal({']c', bang = true})
                else
                    require('gitsigns').nav_hunk('next')
                end
            end
            },
            { '<leader>hQ', function() require('gitsigns').setqflist('all') end },
            { '<leader>hq', function() require('gitsigns').setqflist() end },
        },
        event = "BufEnter"
    },
    {
        "kdheepak/lazygit.nvim",
        lazy = true,
        cmd = {
            "LazyGit",
            "LazyGitConfig",
            "LazyGitCurrentFile",
            "LazyGitFilter",
            "LazyGitFilterCurrentFile",
        },
        -- optional for floating window border decoration
        dependencies = {
            "nvim-lua/plenary.nvim",
        },
        -- setting the keybinding for LazyGit with 'keys' is recommended in
        -- order to load the plugin when the command is run for the first time
        keys = {
            {
                "<C-x>l",
                "<cmd>LazyGit<cr>",
                mode = { "n", "i", "t" },
                desc = "LazyGit",
            }
        }
    },
    {
        "sindrets/diffview.nvim",
        cmd = {
            "DiffviewOpen",
            "DiffviewFileHistory",
            "DiffviewClose",
            "DiffviewFocusFiles",
            "DiffviewToggleFiles",
            "DiffviewRefresh",
            "DiffviewLog",
        }
    }
    -- {
    --     'https://gitlab.com/gitlab-org/editor-extensions/gitlab.vim.git',
    --     -- Activate when a file is created/opened
    --     event = { 'BufReadPre', 'BufNewFile' },
    --     -- Activate when a supported filetype is open
    --     ft = { 'go', 'javascript', 'python', 'ruby' },
    --     cond = function()
    --         -- Only activate if token is present in environment variable.
    --         -- Remove this line to use the interactive workflow.
    --         return vim.env.GITLAB_TOKEN ~= nil and vim.env.GITLAB_TOKEN ~= ''
    --     end,
    --     opts = {
    --         statusline = {
    --             -- Hook into the built-in statusline to indicate the status
    --             -- of the GitLab Duo Code Suggestions integration
    --             enabled = true,
    --         },
    --     },
    -- }
}
