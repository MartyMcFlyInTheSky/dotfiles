-- Config adapted from https://github.com/folke/lazydev.nvim
return {
    {
        "folke/lazydev.nvim",
        ft = "lua", -- only load on lua files
        opts = {
            library = {
                -- See the configuration section for more details
                -- Load luvit types when the `vim.uv` word is found
                { path = "${3rd}/luv/library", words = { "vim%.uv" } },
                "nvim-dap-ui" -- recommended by nvim-dap-ui
            },
            -- -- disable when a .luarc.json file is found (don't override jsonc stored lsp settings)
            -- enabled = function(root_dir)
            --     return not vim.uv.fs_stat(root_dir .. "/.luarc.json")
            -- end,
        },
    },
}
