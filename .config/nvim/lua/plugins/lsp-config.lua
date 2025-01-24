local on_init_lua = function(client)
    if client.workspace_folders then
        local path = client.workspace_folders[1].name
        if vim.loop.fs_stat(path .. '/.luarc.json') or vim.loop.fs_stat(path .. '/.luarc.jsonc') then
            return
        end
    end

    client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
        runtime = {
            -- Tell the language server which version of Lua you're using
            -- (most likely LuaJIT in the case of Neovim)
            version = 'LuaJIT'
        },
        -- Make the server aware of Neovim runtime files
        workspace = {
            checkThirdParty = false,
            -- library = {
            --     vim.env.VIMRUNTIME
            --     -- Depending on the usage, you might want to add additional paths here.
            --     -- "${3rd}/luv/library"
            --     -- "${3rd}/busted/library",
            -- }
            -- or pull in all of 'runtimepath'. NOTE: this is a lot slower and will cause issues when working on your own configuration (see https://github.com/neovim/nvim-lspconfig/issues/3189)
            library = vim.api.nvim_get_runtime_file("", true)
        }
    })
end


-- Use on_attach function instead of lazy keymaps to only bind the keymaps on LspAttach
local on_attach = function(client, bufnr)
    if client.name == "clangd" then
        vim.keymap.set('n', '<A-o>', '<cmd>ClangdSwitchSourceHeader<cr>', { noremap = true, silent = true })
        -- Not sure if still required but proposed by https://www.youtube.com/watch?v=lsFoZIg-oDs
        client.server_capabilities.signatureHelpProvider = false
    end
    -- Displays hover information about the symbol under the cursor
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, { noremap = true, silent = true })
    -- Jump to definition
    -- <C-t> / <C-t>
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { noremap = true, silent = true })
    -- Jump to declaration
    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, { noremap = true, silent = true })
    -- List all the implementations for the symbol under the cursor
    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, { noremap = true, silent = true })
    -- Jumps to the definition of the type symbol
    vim.keymap.set('n', 'go', vim.lsp.buf.type_definition, { noremap = true, silent = true })
    -- Lists all the references
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, { noremap = true, silent = true })
    -- Displays a functin's signature information
    vim.keymap.set('n', 'gs', vim.lsp.buf.signature_help, { noremap = true, silent = true })
    -- Renames all the references to the symbol under the cursor
    vim.keymap.set('n', 'R', vim.lsp.buf.rename, { noremap = true, silent = true })
    -- Selects a code action avalable at the current cursor position
    vim.keymap.set('n', '<F4>', vim.lsp.buf.code_action, { noremap = true, silent = true })
    -- Show diagnostics in a floating window
    vim.keymap.set('n', 'gl', vim.diagnostic.open_float, { noremap = true, silent = true })
    -- Move to the previous diagnostic
    vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { noremap = true, silent = true })
    -- Move to the next diagnostic
    vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { noremap = true, silent = true })

    -- Telescope integration
    vim.keymap.set('n', '<leader>fr', '<cmd>Telescope lsp_references<cr>',
        { noremap = true, silent = true, desc = 'Show references for current token' })
    vim.keymap.set('n', '<leader>dl', '<cmd>Telescope diagnostics<cr>',
        { noremap = true, silent = true, desc = 'List diagnostic information' })
end


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
        event = { "BufReadPre", "BufNewFile" },
        config = function()
            local lsp_capabilities = require('cmp_nvim_lsp').default_capabilities()

            local lspconfig = require("lspconfig")
            lspconfig["lua_ls"].setup({
                on_attach = on_attach,
                filetypes = { "lua" },
                capabilities = lsp_capabilities,
                on_init = on_init_lua,
                settings = {
                    Lua = {}
                }
            })
            lspconfig["bashls"].setup({
                on_attach = on_attach,
                filetypes = { "sh", "bash" },
                capabilities = lsp_capabilities,
            })
            lspconfig["pyright"].setup({
                on_attach = on_attach,
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
            lspconfig["ruff"].setup({
                on_attach = on_attach,
            })
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
            lspconfig["clangd"].setup({
                on_attach = on_attach,
                -- filetypes = { "c", "cpp", "h", "hpp" },
                capabilities = lsp_capabilities,
            })
        end,
    },
}
