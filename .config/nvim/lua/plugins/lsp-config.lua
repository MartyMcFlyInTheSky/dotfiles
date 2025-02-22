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
    -- Displays hover information about the symbol under the cursor
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, { noremap = true, silent = true, buffer = bufnr })
    -- Jump to definition
    -- <C-t> / <C-t>
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { noremap = true, silent = true, buffer = bufnr })
    -- Jump to declaration
    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, { noremap = true, silent = true, buffer = bufnr })
    -- List all the implementations for the symbol under the cursor
    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, { noremap = true, silent = true, buffer = bufnr })
    -- Jumps to the definition of the type symbol
    vim.keymap.set('n', 'go', vim.lsp.buf.type_definition, { noremap = true, silent = true, buffer = bufnr })
    -- Lists all the references
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, { noremap = true, silent = true, buffer = bufnr })
    -- Displays a functin's signature information
    vim.keymap.set('n', 'gs', vim.lsp.buf.signature_help, { noremap = true, silent = true, buffer = bufnr })
    -- Renames all the references to the symbol under the cursor
    vim.keymap.set('n', 'R', vim.lsp.buf.rename, { noremap = true, silent = true, buffer = bufnr })
    -- Selects a code action avalable at the current cursor position
    vim.keymap.set('n', '<F4>', vim.lsp.buf.code_action, { noremap = true, silent = true, buffer = bufnr })
    -- Show diagnostics in a floating window
    vim.keymap.set('n', 'gl', vim.diagnostic.open_float, { noremap = true, silent = true, buffer = bufnr })
    -- Move to the previous diagnostic
    vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { noremap = true, silent = true, buffer = bufnr })
    -- Move to the next diagnostic
    vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { noremap = true, silent = true, buffer = bufnr })

    -- Telescope integration
    vim.keymap.set('n', '<leader>fr', '<cmd>Telescope lsp_references<cr>',
        { noremap = true, silent = true, buffer = bufnr, desc = 'Show references for current token' })
    vim.keymap.set('n', '<leader>dl', '<cmd>Telescope diagnostics<cr>',
        { noremap = true, silent = true, buffer = bufnr, desc = 'List diagnostic information' })

    -- Quickfix integration
    vim.keymap.set('n', 'grr', vim.lsp.buf.references,
        { noremap = true, silent = true, buffer = bufnr, desc = 'List diagnostic information' })

    -- Highlight reference under cursor
    -- if client.resolved_capabilities.document_highlight then
    --     vim.cmd [[
    --   hi! LspReferenceRead cterm=bold ctermbg=235 guibg=LightYellow
    --   hi! LspReferenceText cterm=bold ctermbg=235 guibg=LightYellow
    --   hi! LspReferenceWrite cterm=bold ctermbg=235 guibg=LightYellow
    --   ]]
    --     vim.api.nvim_create_augroup('lsp_document_highlight', {})
    --     vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
    --         group = 'lsp_document_highlight',
    --         buffer = 0,
    --         callback = vim.lsp.buf.document_highlight,
    --     })
    --     vim.api.nvim_create_autocmd('CursorMoved', {
    --         group = 'lsp_document_highlight',
    --         buffer = 0,
    --         callback = vim.lsp.buf.clear_references,
    --     })
    -- end

    -- Autoformat command
    -- local augroup = vim.api.nvim_create_augroup("LspFormatting", {})
    -- if client.supports_method("textDocument/formatting") then
    --     vim.api.nvim_clear_autocmds({
    --         group = augroup,
    --         buffer = bufnr,
    --     })
    --     vim.api.nvim_create_autocmd("BufWritePre", {
    --         group = augroup,
    --         buffer = bufnr,
    --         callback = function()
    --             vim.lsp.buf.format({ bufnr = bufnr })
    --         end,
    --     })
    -- end
end


return {
    {
        "williamboman/mason.nvim",
        opts = {}, -- without opts the setup function is not called
        cmd = { "Mason" },
    },
    {
        "williamboman/mason-lspconfig.nvim",
        dependencies = {
            "williamboman/mason.nvim",
            "neovim/nvim-lspconfig",
        },
        event = { "BufReadPre", "BufNewFile" },
        cmd = { "LspInstall", "LspUninstall" },
        opts = {
            ensure_installed = {
                "lua_ls",
                "pyright",
                "bashls",
                "ruff",
                "clangd",
            },
            -- Automatically install the LSP servers configured in nvim-lspconfig
            automatic_installation = false,
            handlers = {
                function(server_name)
                    local lsp_capabilities = require('cmp_nvim_lsp').default_capabilities()
                    require("lspconfig")[server_name].setup({
                        on_attach = on_attach,
                        capabilities = lsp_capabilities,
                    })
                end,
                ["lua_ls"] = function()
                    local lsp_capabilities = require('cmp_nvim_lsp').default_capabilities()
                    require("lspconfig")["lua_ls"].setup({
                        on_attach = on_attach,
                        on_init = on_init_lua,
                        capabilities = lsp_capabilities,
                        settings = {
                            Lua = {
                                diagnostics = {
                                    globals = { "vim" }
                                }
                            }
                        }
                    })
                end,
                ["pyright"] = function()
                    local lsp_capabilities = require('cmp_nvim_lsp').default_capabilities()
                    require("lspconfig")["pyright"].setup({
                        on_attach = on_attach,
                        capabilities = lsp_capabilities,
                        pyright = {
                            -- Using Ruff's import organizer
                            disableOrganizeImports = true, -- This is taken care of by isort (I think)
                        },
                        python = {
                            analysis = {
                                -- Ignore all files for analysis to exclusively use Ruff for linting
                                ignore = { "*" },
                            },
                        },
                    })
                end,
                ["clangd"] = function()
                    local lsp_capabilities = require('cmp_nvim_lsp').default_capabilities()
                    require("lspconfig")["clangd"].setup({
                        on_attach = function(client, bufnr)
                            -- Special clangd switch header and source
                            vim.keymap.set('n', '<A-o>', '<cmd>ClangdSwitchSourceHeader<cr>',
                                { noremap = true, silent = true, buffer = bufnr })
                            -- Not sure if still required but proposed by https://www.youtube.com/watch?v=lsFoZIg-oDs
                            client.server_capabilities.signatureHelpProvider = false
                            -- Default setup
                            on_attach(client, bufnr)
                        end,
                        capabilities = lsp_capabilities,
                    })
                end,
            }
        },
    },
    {
        "nvimtools/none-ls.nvim",
        opts = function()
            local augroup = vim.api.nvim_create_augroup("LspFormatting", {})
            return {
                on_attach = function(client, bufnr)
                    if client.supports_method("textDocument/formatting") then
                        vim.api.nvim_clear_autocmds({
                            group = augroup,
                            buffer = bufnr,
                        })
                        vim.api.nvim_create_autocmd("BufWritePre", {
                            group = augroup,
                            buffer = bufnr,
                            callback = function()
                                vim.lsp.buf.format({ bufnr = bufnr })
                            end,
                        })
                    end
                end,
            }
        end
    },
    {
        "jay-babu/mason-null-ls.nvim",
        event = { "BufReadPre", "BufNewFile" },
        cmd = { "NullLsInstall", "NoneLsInstall", "NullLsUninstall", "NoneLsUninstall" },
        dependencies = {
            "williamboman/mason.nvim",
            "nvimtools/none-ls.nvim",
        },
        opts = {
            ensure_installed = {
                "black", "isort", "mypy",
                "stylua",
                "shftm",
                "clang_format",
            },
            automatic_installation = false,
            handlers = {
                function(source_name, methods)
                    require('mason-null-ls').default_setup(source_name, methods)
                end,
                ["black"] = function()
                    local null_ls = require("null-ls")
                    null_ls.register(null_ls.builtins.formatting.black.with({
                        extra_args = { "--line-length", "120" }
                    }))
                end,
                -- function(source_name, methods)
                --     vim.notify("Setting up Null LS for " .. source_name)
                --     local null_ls = require("null-ls")
                --     null_ls.register(null_ls.builtins.formatting.stylua
                --     -- require("mason-null-ls").default_setup(source_name, methods)
                -- end
            },
        },
        keys = {
            { "<leader>gf", vim.lsp.buf.format, {} },
        },
    }
}
