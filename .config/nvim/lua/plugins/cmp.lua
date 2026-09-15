return {
    { -- optional blink completion source for require statements and module annotations
        "saghen/blink.cmp",
        commit = "f85eb62",
        build = 'cargo build --release',
        event = "InsertEnter",
        dependencies = {
            { "folke/lazydev.nvim" },  -- optional: provides snippets for the snippet source
            { 'rafamadriz/friendly-snippets' },
        },
        opts = {

            -- All presets have the following mappings:
            -- C-space: Open menu or open docs if already open
            -- C-n/C-p or Up/Down: Select next/previous item
            -- C-e: Hide menu
            -- C-k: Toggle signature help (if signature.enabled = true)

            -- See :h blink-cmp-config-keymap for defining your own keymap
            keymap = {
                preset = 'default',
                ['<C-u>'] = { 'scroll_signature_up', 'fallback' },
                ['<C-d>'] = { 'scroll_signature_down', 'fallback' },
                ["<C-n>"] = { "show", "select_next", "fallback" },
                ["<C-p>"] = { "show", "select_prev", "fallback" },

                -- default in all keymap presets
                ['<C-k>'] = { 'show_signature', 'hide_signature', 'fallback' },
            },

            appearance = {
                -- 'mono' (default) for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
                -- Adjusts spacing to ensure icons are aligned
                nerd_font_variant = 'mono'
            },

            -- (Default) Only show the documentation popup when manually triggered
            completion = {
                documentation = { auto_show = false },
                menu = { auto_show = false },
                -- ghost_text = { enabled = true },
            },

            signature = { enabled = true },

            sources = {
                -- add lazydev to your completion providers
                -- Exempt completion in comments (from https://cmp.saghen.dev/recipes#dynamically-picking-providers-by-treesitter-node-filetype)
                default = function(_)
                    local success, node = pcall(vim.treesitter.get_node)
                    if success and node and vim.tbl_contains({ 'comment', 'line_comment', 'block_comment' }, node:type()) then
                        return {}
                    elseif vim.bo.filetype == 'lua' then
                        return { "lazydev", "lsp", "path", "snippets", "buffer" }
                    else
                        return { 'lsp', 'path', 'snippets', 'buffer'}
                    end
                end,
                providers = {
                    lazydev = {
                        name = "LazyDev",
                        module = "lazydev.integrations.blink",
                        -- make lazydev completions top priority (see `:h blink.cmp`)
                        score_offset = 100,
                    },
                },
            },

            -- See the fuzzy documentation for more information
            fuzzy = { implementation = "prefer_rust_with_warning" },
        },
    }
}
