return {
    'nvim-telescope/telescope.nvim',
    tag = '0.1.8',
    dependencies = { 'nvim-lua/plenary.nvim' },
    opts = {
        defaults = {
            mappings = {
                -- Allow single esc close (https://www.reddit.com/r/neovim/comments/pzxw8h/telescope_quit_on_first_single_esc/)
                i = {
                    ["<esc>"] = require("telescope.actions").close,
                },
            },
        },
    },
    keys={
        {'<leader>fg', "<cmd>Telescope live_grep<cr>", desc = "Live grep"},
    	{'<C-p>', "<cmd>Telescope find_files<cr>", desc = "Find files"},
    }
}
