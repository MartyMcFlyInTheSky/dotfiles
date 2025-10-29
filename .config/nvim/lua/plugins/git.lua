return {
    {
        'lewis6991/gitsigns.nvim',
        opts = {
            -- worktrees = {
            --     {
            --         toplevel = vim.env.HOME,
            --         gitdir = vim.env.HOME .. '/.myconfig'
            --     }
            -- }
        },
        config = function(_, opts)
            require("gitsigns").setup(opts)

            vim.keymap.set({'o', 'x'}, 'ih', '<Cmd>Gitsigns select_hunk<CR>')
        end,
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
            { "<leader>l","<cmd>LazyGit<cr>", desc = "LazyGit" }
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
