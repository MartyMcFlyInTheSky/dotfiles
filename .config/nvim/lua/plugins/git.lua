return {
    {
        "kdheepak/lazygit.nvim",
        cmd = {
            "LazyGit",
            "LazyGitconfig",
            "LazyGitCurrentFile",
            "LazyGitFilter",
            "LazyGitFilterCurrentFile",
        },
        dependencies = {
            "nvim-lua/plenary.nvim",
        },
        keys = {
            { "<leader>lg", "<cmd>LazyGit<cr>", desc = "Open lazy git" },
        },
    },
    {
        'lewis6991/gitsigns.nvim',
        opts = {
            worktrees = {
                {
                    toplevel = vim.env.HOME,
                    gitdir = vim.env.HOME .. '/.myconfig'
                }
            }
        },
        keys = {
            -- Jump to previous / next hunk
            { "<leader>hn", function() require('gitsigns').nav_hunk('next') end, desc = "Next hunk" },
            { "<leader>hp", function() require('gitsigns').nav_hunk('prev') end, desc = "Next hunk" },

            -- Staging / unstaging hunk or whole file
            { "<leader>hs", function() require('gitsigns').stage_hunk() end, desc = "Stage hunk" },
            { "<leader>hr", function() require('gitsigns').reset_hunk() end, desc = "Reset hunk" },

            { "<leader>hS", function() require('gitsigns').stage_buffer() end, desc = "Stage buffer" },
            { "<leader>hR", function() require('gitsigns').reset_buffer() end, desc = "Reset buffer" },

            -- Preview
            { "<leader>hv", function() require('gitsigns').preview_hunk() end, desc = "Preview hunk" },
            { "<leader>hi", function() require('gitsigns').preview_hunk_inline() end, desc = "Preview hunk inline" },

            -- Blame
            { "<leader>hb", function() require('gitsigns').blame_line({ full = true }) end, desc = "Blame line" },

            -- Diff
            { "<leader>hd", function() require('gitsigns').diffthis() end, desc = "Diff hunk" },
            { "<leader>hD", function() require('gitsigns').diffthis('~') end, desc = "Diff whole file" },

            -- Quickfix integration	
            { "<leader>hq", function() require('gitsigns').setqflist(0) end, desc = "Put current buffer changes into quickfix list" },
            { "<leader>hQ", function() require('gitsigns').setqflist('all') end, desc = "Put all changes in quickfix list" },

            -- Toggles
            { "<leader>tb", function() require('gitsigns').toggle_current_line_blame() end, desc = "Toggle current line blame" },
            -- { "<leader>td", function() require('gitsigns').toggle_deleted() end, desc = "Toggle deleted" },
            { "<leader>tw", function() require('gitsigns').toggle_word_diff() end, desc = "Toggle current word diff" },

            -- Text object
            { "ih", function() require('gitsigns').select_hunk() end, mode = { "o", "x" }, desc = "Textobject select hunk" },
        },
    }
}
