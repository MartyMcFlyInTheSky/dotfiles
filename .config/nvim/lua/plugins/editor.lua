return {
    {
        'windwp/nvim-autopairs',
        opts = {},
        event = "InsertEnter",
    },
    {
        'Wansmer/treesj',
        dependencies = {
            'nvim-treesitter/nvim-treesitter',
        },
        opts = {
            use_default_keymaps = false,
        },
        keys = {
            {"gJ", function() require('treesj').split() end, { desc="Split treesitter aware"}},
            {"J", function() require('treesj').join() end, { desc="Join treesitter aware"}},
        },
        cmd = { "TSJToggle", "TSJoin", "TSSplit" },
    }
}
