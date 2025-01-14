return {
    {
        "rust-lang/rust.vim",
        ft = "rust",
        init = function()
            vim.g.rustfmt_autosave = 1
        end,
    },
    {
        'saecki/crates.nvim',
        ft = {"toml"},
        opts = function()
            require('cmp').setup.buffer({
                sources = { { name = "crates" }}
            })
            return {
                completion = {
                    cmp = {
                        enabled = true,
                    }
                }
            }
        end,
    },
    {
        "mrcjkb/rustaceanvim",
        version = '^5',
        -- This is a filetype specific plugin that works out of the box without
        -- the need to call setup()
        -- ["rust-analyzer"] = {
        --     cargo = {
        --         allFeatures = true,
        --     }
        -- },
        config = function()

            -- Where to look for codelldb
            local mason_registry = require('mason-registry')
            local codelldb = mason_registry.get_package("codelldb")
            local extension_path = codelldb:get_install_path() .. "/extension/"
            local codelldb_path = extension_path .. "adapter/codelldb"
            local liblldb_path = extension_path.. "lldb/lib/liblldb.dylib"
            local cfg = require('rustaceanvim.config')

            vim.g.rustaceanvim = {
                server = {
                    on_attach = function(client, bufnr)
                        vim.keymap.set("n", "<leader>ra", function() vim.cmd.RustLsp('codeAction') end, { silent=true, buffer = bufnr})
                        vim.keymap.set("n", "<leader>rJ", function() vim.cmd.RustLsp('joinLines') end, { silent=true})
                        vim.keymap.set("n", "<leader>rK", function() vim.cmd.RustLsp({'hover', 'actions'}) end, { silent=true})
                        vim.keymap.set("n", "<leader>rc", function() vim.cmd.RustLsp('openCargo') end, { silent=true})
                    end,
                    default_settings = {
                        ['rust-analyzer'] = {
                            cargo = {
                                allFeatures = true,
                            }
                        }
                    }
                },
                dap = {
                    adapter = cfg.get_codelldb_adapter(codelldb_path, liblldb_path)
                }
            }
        end,
        lazy = false, -- The plugin is lazy loaded
    }
}
