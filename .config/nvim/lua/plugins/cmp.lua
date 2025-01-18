return {
    -- Lsp suggestions
    {
        -- Check the lspconfig to see capabilities injected to the lsp setups
        "hrsh7th/cmp-nvim-lsp",
    },
    -- Lua snippets
    {
        "L3MON4D3/LuaSnip",
        dependencies = {
            "saadparwaiz1/cmp_luasnip",
            "rafamadriz/friendly-snippets",
        }
    },
    -- Copilot & suggestions
    {
        "zbirenbaum/copilot.lua",
        cmd = "Copilot",
        event = "InsertEnter",
        opts = {
            suggestion = { enabled = false },
            panel = { enabled = false },
        },
        config = function(_, opts)
            require("copilot").setup(opts)
        end,
    },
    {
        "zbirenbaum/copilot-cmp",
        dependencies = {
            "zbirenbaum/copilot.lua"
        },
        opts = {},
        config = function(_, opts)
            require("copilot_cmp").setup(opts)
        end
    },

    ----------------------------
    {
        "hrsh7th/nvim-cmp",
        dependencies = {
            "hrsh7th/cmp-nvim-lsp",
            "zbirenbaum/copilot-cmp",
            "L3MON4D3/LuaSnip",
        },
        opts = function()
            local cmp = require("cmp")
            require("luasnip.loaders.from_vscode").lazy_load()

            return {
                sorting = {
                    priority_weight = 2,
                    comparators = {
                        require("copilot_cmp.comparators").prioritize,

                        -- Below is the default comparitor list and order for nvim-cmp
                        cmp.config.compare.offset,
                        -- cmp.config.compare.scopes, --this is commented in nvim-cmp too
                        cmp.config.compare.exact,
                        cmp.config.compare.score,
                        cmp.config.compare.recently_used,
                        cmp.config.compare.locality,
                        cmp.config.compare.kind,
                        cmp.config.compare.sort_text,
                        cmp.config.compare.length,
                        cmp.config.compare.order,
                    },
                },
                snippet = {
                    -- REQUIRED - you must specify a snippet engine
                    -- When you click on a snippet these functions will expand it
                    expand = function(args)
                        require("luasnip").lsp_expand(args.body) -- For `luasnip` users.
                    end,
                },
                window = {
                    completion = cmp.config.window.bordered(),
                    documentation = cmp.config.window.bordered(),
                },
                mapping = cmp.mapping.preset.insert({
                    ["<C-b>"] = cmp.mapping.scroll_docs(-4),
                    ["<C-f>"] = cmp.mapping.scroll_docs(4),
                    ["<C-Space>"] = cmp.mapping.complete(),
                    ["<C-e>"] = cmp.mapping.abort(),
                    ["<CR>"] = cmp.mapping.confirm({ select = false }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
                }),
                sources = cmp.config.sources({
                    { name = 'luasnip', group_index = 2 },
                    { name = 'copilot', group_index = 2 },
                    { name = 'nvim_lsp', group_index = 2 },
                }, {
                    { name = "buffer" },
                }),
            }
        end,
        lazy = false,
    },
}
