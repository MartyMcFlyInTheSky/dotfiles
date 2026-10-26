-- nvim-treesitter main branch (nvim 0.12+)
-- API changed completely from master branch:
--   - setup() only accepts install_dir
--   - parsers installed via require('nvim-treesitter').install()
--   - highlight/fold/indent wired via FileType autocmd (builtin nvim features)
--   - textobjects plugin has new explicit keymap API
return {
    {
        "nvim-treesitter/nvim-treesitter",
        dependencies = {
            {
                "nvim-treesitter/nvim-treesitter-textobjects",
                branch = "main",
            },
        },
        branch = "main",
        lazy = false,
        build = ":TSUpdate",
        init = function()
            -- Install parsers on startup (no-op if already installed)
            local parsers = {
                "bash", "c", "cpp", "lua", "vim", "vimdoc", "query",
                "markdown", "markdown_inline", "yaml",
                "python", "json5", "wgsl",
            }
            require("nvim-treesitter").install(parsers)
        end,
        config = function()
            -- setup() in main branch only accepts install_dir; default is fine
            -- require("nvim-treesitter").setup {}

            -- Highlighting, folding, indentation are builtin nvim features;
            -- enable them per-filetype via autocmd
            vim.api.nvim_create_autocmd("FileType", {
                callback = function()
                    -- Highlighting
                    local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(0))
                    local too_large = ok and stats and stats.size > 200 * 1024
                    if not too_large then
                        pcall(vim.treesitter.start)
                    end

                    -- Folding
                    vim.wo[0][0].foldmethod = "expr"
                    vim.wo[0][0].foldexpr = "v:lua.vim.treesitter.foldexpr()"
                    vim.opt_local.foldlevel = 99
                    vim.opt_local.foldlevelstart = 99

                    -- Indentation (experimental)
                    vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
                end,
            })

            -- Incremental selection (builtin nvim feature via nvim-treesitter queries)
            vim.keymap.set("n", "U", function()
                vim.cmd("normal! V")
                require("nvim-treesitter.incremental_selection").init_selection()
            end, { desc = "TS: start incremental selection" })

            -- ── textobjects: select ──────────────────────────────────────────
            local sel = require("nvim-treesitter-textobjects.select")
            local function map_sel(lhs, query, desc)
                vim.keymap.set({ "x", "o" }, lhs, function()
                    sel.select_textobject(query, "textobjects")
                end, { desc = desc })
            end

            map_sel("a=", "@assignment.outer", "outer assignment")
            map_sel("i=", "@assignment.inner", "inner assignment")
            map_sel("r=", "@assignment.rhs",   "rhs of assignment")
            map_sel("aa", "@parameter.outer",  "outer parameter")
            map_sel("ia", "@parameter.inner",  "inner parameter")
            map_sel("ai", "@conditional.outer","outer conditional")
            map_sel("ii", "@conditional.inner","inner conditional")
            map_sel("al", "@loop.outer",        "outer loop")
            map_sel("il", "@loop.inner",        "inner loop")
            map_sel("af", "@call.outer",        "outer function call")
            map_sel("if", "@call.inner",        "inner function call")
            map_sel("am", "@function.outer",    "outer method/fn def")
            map_sel("im", "@function.inner",    "inner method/fn def")
            map_sel("ac", "@class.outer",       "outer class")
            map_sel("ic", "@class.inner",       "inner class")

            -- ── textobjects: swap ────────────────────────────────────────────
            local swap = require("nvim-treesitter-textobjects.swap")
            vim.keymap.set("n", "<C-A-l>", function()
                swap.swap_next("@parameter.inner")
            end, { desc = "TS: swap param with next" })
            vim.keymap.set("n", "<C-A-h>", function()
                swap.swap_previous("@parameter.inner")
            end, { desc = "TS: swap param with prev" })

            -- ── textobjects: move ────────────────────────────────────────────
            require("nvim-treesitter-textobjects").setup { move = { set_jumps = true } }
            local move = require("nvim-treesitter-textobjects.move")
            local function map_move(lhs, fn, query, desc)
                vim.keymap.set({ "n", "x", "o" }, lhs, function()
                    move[fn](query, "textobjects")
                end, { desc = desc })
            end

            -- next start
            map_move("]f", "goto_next_start", "@call.outer",        "Next fn call start")
            map_move("]m", "goto_next_start", "@function.outer",    "Next method start")
            map_move("]c", "goto_next_start", "@class.outer",       "Next class start")
            map_move("]i", "goto_next_start", "@conditional.outer", "Next conditional start")
            map_move("]l", "goto_next_start", "@loop.outer",        "Next loop start")
            -- next end
            map_move("]F", "goto_next_end",   "@call.outer",        "Next fn call end")
            map_move("]M", "goto_next_end",   "@function.outer",    "Next method end")
            map_move("]C", "goto_next_end",   "@class.outer",       "Next class end")
            map_move("]I", "goto_next_end",   "@conditional.outer", "Next conditional end")
            map_move("]L", "goto_next_end",   "@loop.outer",        "Next loop end")
            map_move("]A", "goto_next_end",   "@parameter.inner",   "Next param end")
            -- prev start
            map_move("[f", "goto_previous_start", "@call.outer",        "Prev fn call start")
            map_move("[m", "goto_previous_start", "@function.outer",    "Prev method start")
            map_move("[c", "goto_previous_start", "@class.outer",       "Prev class start")
            map_move("[i", "goto_previous_start", "@conditional.outer", "Prev conditional start")
            map_move("[l", "goto_previous_start", "@loop.outer",        "Prev loop start")
            -- prev end
            map_move("[F", "goto_previous_end", "@call.outer",        "Prev fn call end")
            map_move("[M", "goto_previous_end", "@function.outer",    "Prev method end")
            map_move("[C", "goto_previous_end", "@class.outer",       "Prev class end")
            map_move("[I", "goto_previous_end", "@conditional.outer", "Prev conditional end")
            map_move("[L", "goto_previous_end", "@loop.outer",        "Prev loop end")
            map_move("[A", "goto_previous_end", "@parameter.inner",   "Prev param end")

            -- scope / fold jumps (use locals/folds query groups)
            vim.keymap.set({ "n", "x", "o" }, "]s", function()
                move.goto_next_start("@local.scope", "locals")
            end, { desc = "Next scope" })
            vim.keymap.set({ "n", "x", "o" }, "]z", function()
                move.goto_next_start("@fold", "folds")
            end, { desc = "Next fold" })
        end,
    },
}
