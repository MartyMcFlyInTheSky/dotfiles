return {
    'stevearc/oil.nvim',
    opts = {},
    -- dependencies = { { "echasnovski/mini.icons", opts = {} } },
    dependencies = { "nvim-tree/nvim-web-devicons" }, -- use if prefer nvim-web-devicons
    config = function()
        vim.keymap.set('n', '-', "<CMD>Oil<CR>", { desc = "Open parent directory" })
        vim.keymap.set('n', '<leader>pv', "<CMD>Oil<CR>", { desc = "Open parent directory" })
        require("oil").setup({
            default_file_explorer = true,
            delete_to_trash = true,
            skip_confirm_for_simple_edits = true,
            view_options = {
                show_hidden = true,
                natural_order = true,
            },
            win_options = {
                wrap = true,
            }
        })

    end
}
