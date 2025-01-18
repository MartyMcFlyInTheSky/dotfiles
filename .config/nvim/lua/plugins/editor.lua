return {
    {
        "lukas-reineke/indent-blankline.nvim",
        main = "ibl",
        opts = {},
        lazy = false,
    },
    {
        'windwp/nvim-autopairs',
        opts = {},
        event = "InsertEnter",
    },
    -- rainbow parens
    {
        "HiPhish/rainbow-delimiters.nvim",
        event = "BufRead",
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
