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
            local lsp_capabilities = require('cmp_nvim_lsp').default_capabilities()

            local lspconfig = require("lspconfig")
            lspconfig["lua_ls"].setup({
                filetypes = { "lua" },
                capabilities = lsp_capabilities,
            })
            lspconfig["bashls"].setup({
                filetypes = { "sh", "bash" },
                capabilities = lsp_capabilities,
            })
            lspconfig["pyright"].setup({
                filetypes = { "python" },
                capabilities = lsp_capabilities,
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
            -- Displays hover information about the symbol under the cursor
            { "K",         vim.lsp.buf.hover,       {} },
            -- Jump to definition
            { "gd",        vim.lsp.buf.definition,  {} },
            -- Jump to declaration
            { "gD",        vim.lsp.buf.declaration,  {} },
            -- List all the implementations for the symbol under the cursor
            { "gi",        vim.lsp.buf.implementation,  {} },
            -- Jumps to the definition of the type symbol
            { "go",        vim.lsp.buf.type_definition,  {} },
            -- Lists all the references
            { "gr",        vim.lsp.buf.references,  {} },
            -- Displays a functin's signature information
            { "gs",        vim.lsp.buf.signature_help,  {} },
            -- Renames all the references to the symbol under the cursor
            { "<F2>",        vim.lsp.buf.rename,  {} },
            -- Selects a code action avalable at the current cursor position 
            { "<F4>", vim.lsp.buf.code_action, {} },
            -- Show diagnostics in a floating window
            { "gl", vim.diagnostic.open_float, {} },
            -- Move to the previous diagnostic
            { "[d", vim.diagnostic.goto_prev, {} },
            -- Move to the next diagnostic
            { "]d", vim.diagnostic.goto_next, {} },
        },
        lazy = false,
    },
}
