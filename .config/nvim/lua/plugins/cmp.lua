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
            -- It's suggested to disable these options for copilot-cmp
            suggestion = { enabled = false },
            panel = { enabled = false },
        },
    },
    {
        "zbirenbaum/copilot-cmp",
        dependencies = { "zbirenbaum/copilot.lua" },
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
        event = { "InsertEnter", "CmdlineEnter" },
        opts = function()
            -- vim.opt.completeopt = { "menu", "menuone", "noselect" }

            local cmp = require("cmp")
            require("luasnip.loaders.from_vscode").lazy_load()

            local has_words_before = function()
                if vim.api.nvim_buf_get_option(0, "buftype") == "prompt" then return false end
                local line, col = unpack(vim.api.nvim_win_get_cursor(0))
                return col ~= 0 and vim.api.nvim_buf_get_text(0, line - 1, 0, line - 1, col, {})[1]:match("^%s*$") == nil
            end

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
                    ["<Tab>"] = vim.schedule_wrap(function(fallback)
                        if cmp.visible() and has_words_before() then
                            cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
                        else
                            fallback()
                        end
                    end),
                    -- end, { "i", "s", "c", }),
                }),
                sources = cmp.config.sources({
                    { name = 'luasnip',  group_index = 2 },
                    { name = 'nvim_lsp', group_index = 2 },
                    { name = 'copilot',  group_index = 2 },
                }, {
                    { name = "buffer" },
                }),
            }
        end,
    },
}
