return {
    {
        'stevearc/oil.nvim',
        opts = {
            view_options = {
                show_hidden = true,
            },
            keymaps = {
                -- ["g?"] = { "actions.show_help", mode = "n" },
                -- ["<CR>"] = "actions.select",
                -- ["<C-s>"] = { "actions.select", opts = { vertical = true } },
                -- ["<C-h>"] = { "actions.select", opts = { horizontal = true } },
                -- ["<C-t>"] = { "actions.select", opts = { tab = true } },
                ["<C-p>"] = false,
                ["<A-p>"] = "actions.preview",
                -- ["<C-c>"] = { "actions.close", mode = "n" },
                -- ["<C-l>"] = "actions.refresh",
                -- ["-"] = { "actions.parent", mode = "n" },
                -- ["_"] = { "actions.open_cwd", mode = "n" },
                -- ["`"] = { "actions.cd", mode = "n" },
                -- ["~"] = { "actions.cd", opts = { scope = "tab" }, mode = "n" },
                -- ["gs"] = { "actions.change_sort", mode = "n" },
                -- ["gx"] = "actions.open_external",
                -- ["g."] = { "actions.toggle_hidden", mode = "n" },
                -- ["g\\"] = { "actions.toggle_trash", mode = "n" },
            },
        },
        -- Use nvim-web-devicons since we use those across other plugins already
        -- dependencies = { { "echasnovski/mini.icons", opts = {} } },
        dependencies = { "nvim-tree/nvim-web-devicons" }, -- use if prefer nvim-web-devicons
        cmd = {
            "Oil",
        },
        keys = {
            { "-", "<cmd>Oil<cr>", {} },
        },
    },
    {
        "mrjones2014/smart-splits.nvim",
        opts = {
            at_edge = 'stop',
        },
        keys = {
            { "<C-h>",  function() require('smart-splits').move_cursor_left() end,     {} },
            { "<C-j>",  function() require('smart-splits').move_cursor_down() end,     {} },
            { "<C-k>",  function() require('smart-splits').move_cursor_up() end,       {} },
            { "<C-l>",  function() require('smart-splits').move_cursor_right() end,    {} },
            { "<C-\\>", function() require('smart-splits').move_cursor_previous() end, {} },
        },
        lazy = false,
    }
}
