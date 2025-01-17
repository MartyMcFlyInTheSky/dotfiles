return {
    {
        "williamboman/mason.nvim",
        opts = {
            -- Ensure installed not available, install these non-lsp tools manually:
            -- mypy
            -- black
        },
    },
    {
        "williamboman/mason-lspconfig.nvim",
        dependencies = { "williamboman/mason.nvim" },
        opts = {
            -- Automatically isntall the LSP servers configured in nvim-lspconfig
            automatic_installation = true,
        },
        lazy = false,
    },
    {
        "neovim/nvim-lspconfig",
        dependencies = { "williamboman/mason-lspconfig.nvim" },
        config = function()
            local capabilities = require('cmp_nvim_lsp').default_capabilities()

            local lspconfig = require("lspconfig")
            lspconfig["lua_ls"].setup({
                filetypes = { "lua" },
                capabilities = capabilities,
            })
            lspconfig["bashls"].setup({
                filetypes = { "sh", "bash" },
                capabilities = capabilities,
            })
            lspconfig["pyright"].setup({
                filetypes = { "python" },
                capabilities = capabilities,
                pyright = {
                    -- Using Ruff's import organizer
                    disableOrganizeImports = true,
                },
                python = {
                    analysis = {
                        -- Ignore all files for analysis to exclusively use Ruff for linting
                        ignore = { "*" },
                    },
                },
            })
            lspconfig["ruff"].setup({})
            -- Disabled since taken care of by rustaceanvim
            -- lspconfig["rust_analyzer"].setup({
            --     root_dir = lspconfig.util.root_pattern("Cargo.toml"),
            --     filetypes = { "rust" },
            --     settings = {
            --         ["rust-analyzer"] = {
            --             cargo = {
            --                 allFeatures = true,
            --             },
            --         },
            --     },
            -- })
        end,
        keys = {
            { "K",         vim.lsp.buf.hover,       {} },
            { "gd",        vim.lsp.buf.definition,  {} },
            { "<leader>a", vim.lsp.buf.code_action, {} },
        },
        lazy = false,
    },
}
