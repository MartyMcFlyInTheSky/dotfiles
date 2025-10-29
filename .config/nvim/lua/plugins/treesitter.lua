return {
    {
        "nvim-treesitter/nvim-treesitter",
        dependencies = { "nvim-treesitter/nvim-treesitter-textobjects" },
        branch = 'master',
        lazy = false, -- Does not support lazy loading
        build = ":TSUpdate",
        config = function()
            local configs = require("nvim-treesitter.configs")
            configs.setup({
                ensure_installed = {
                    "c", "lua", "vim", "vimdoc", "query", "markdown", "markdown_inline",
                    -- Language parsers for C, Lua, Markdown, Vimscript, Vimdoc are 
                    -- installed in neovim by default
                    -- (https://neovim.io/doc/user/treesitter.html#treesitter-parsers)
                    "cpp", "python",
                },
                sync_install = false,
                auto_install = false,
                -- Modules:
                highlight = {
                    enable = true,
                    -- Disable highlight for very large files
                    disable = function(lang, buf)
                        local max_filesize = 200 * 1024 -- 200 KB
                        local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
                        if ok and stats and stats.size > max_filesize then
                            return true
                        end
                    end,
                    additional_vim_regex_highlighting = false,
                },
                indent = {
                    -- Indent for the '=' operator
                    enable = true,
                },
                rainbow = {
                    enable = true,
                    max_file_lines = 3000,
                },
                incremental_selection = {
                    enable = true,
                    keymaps = {
                        init_selection = "gnn", -- set to `false` to disable one of the mappings
                        node_incremental = "g{",
                        node_decremental = "g}",
                        scope_incremental = false,
                    },
                },
                textobjects = {
                    select = {
                        enable = true,
                        lookahead = true,
                        keymaps = {
                            -- You can use the capture groups defined in textobjects.scm
                            ["a="] = { query = "@assignment.outer", desc = "Select outer part of an assignment" },
                            ["i="] = { query = "@assignment.inner", desc = "Select inner part of an assignment" },
                            -- This makes visual selection slower since it has to wait whether I type '=' or not
                            -- ["l="] = { query = "@assignment.lhs", desc = "Select left hand side of an assignment" },
                            ["r="] = { query = "@assignment.rhs", desc = "Select right hand side of an assignment" },

                            ["aa"] = { query = "@parameter.outer", desc = "Select outer part of a parameter/argument" },
                            ["ia"] = { query = "@parameter.inner", desc = "Select inner part of a parameter/argument" },

                            ["ai"] = { query = "@conditional.outer", desc = "Select outer part of a conditional" },
                            ["ii"] = { query = "@conditional.inner", desc = "Select inner part of a conditional" },

                            ["al"] = { query = "@loop.outer", desc = "Select outer part of a loop" },
                            ["il"] = { query = "@loop.inner", desc = "Select inner part of a loop" },

                            ["af"] = { query = "@call.outer", desc = "Select outer part of a function call" },
                            ["if"] = { query = "@call.inner", desc = "Select inner part of a function call" },

                            ["am"] = {
                                query = "@function.outer",
                                desc = "Select outer part of a method/function definition",
                            },
                            ["im"] = {
                                query = "@function.inner",
                                desc = "Select inner part of a method/function definition",
                            },

                            ["ac"] = { query = "@class.outer", desc = "Select outer part of a class" },
                            ["ic"] = { query = "@class.inner", desc = "Select inner part of a class" },
                        },
                    },
                    swap = {
                        enable = true,
                        swap_next = {
                            ["<leader>a"] = "@parameter.inner", -- swap parameters/argument with next
                        },
                        swap_previous = {
                            ["<leader>A"] = "@parameter.inner", -- swap parameters/argument with prev
                        },
                    },
                    move = {
                        enable = true,
                        set_jumps = true, -- whether to set jumps in the jumplist (<C-i> and <C-o>)
                        goto_next_start = {
                            ["]f"] = { query = "@call.outer", desc = "Next function call start" },
                            ["]m"] = { query = "@function.outer", desc = "Next method/function def start" },
                            -- conflicts with jumping to diff
                            -- ["]c"] = { query = "@class.outer", desc = "Next class start" },
                            ["]i"] = { query = "@conditional.outer", desc = "Next conditional start" },
                            ["]l"] = { query = "@loop.outer", desc = "Next loop start" },
                            ["]a"] = { query = "@parameter.inner", desc = "Next parameter start" },

                            -- You can pass a query group to use query from `queries/<lang>/<query_group>.scm file in your runtime path.
                            -- Below example nvim-treesitter's `locals.scm` and `folds.scm`. They also provide highlights.scm and indent.scm.
                            ["]s"] = { query = "@scope", query_group = "locals", desc = "Next scope" },
                            ["]z"] = { query = "@fold", query_group = "folds", desc = "Next fold" },
                        },
                        goto_next_end = {
                            ["]F"] = { query = "@call.outer", desc = "Next function call end" },
                            ["]M"] = { query = "@function.outer", desc = "Next method/function def end" },
                            ["]C"] = { query = "@class.outer", desc = "Next class end" },
                            ["]I"] = { query = "@conditional.outer", desc = "Next conditional end" },
                            ["]L"] = { query = "@loop.outer", desc = "Next loop end" },
                            ["]A"] = { query = "@parameter.inner", desc = "Next parameter end" },
                        },
                        goto_previous_start = {
                            ["[f"] = { query = "@call.outer", desc = "Prev function call start" },
                            ["[m"] = { query = "@function.outer", desc = "Prev method/function def start" },
                            -- conflicts with jumping to diff
                            -- ["[c"] = { query = "@class.outer", desc = "Prev class start" },
                            ["[i"] = { query = "@conditional.outer", desc = "Prev conditional start" },
                            ["[l"] = { query = "@loop.outer", desc = "Prev loop start" },
                            ["[a"] = { query = "@parameter.inner", desc = "Prev parameter start" },
                        },
                        goto_previous_end = {
                            ["[F"] = { query = "@call.outer", desc = "Prev function call end" },
                            ["[M"] = { query = "@function.outer", desc = "Prev method/function def end" },
                            ["[C"] = { query = "@class.outer", desc = "Prev class end" },
                            ["[I"] = { query = "@conditional.outer", desc = "Prev conditional end" },
                            ["[L"] = { query = "@loop.outer", desc = "Prev loop end" },
                            ["[A"] = { query = "@parameter.inner", desc = "Prev paramter end" },
                        },
                    },
                }
            })
        end,
    },
    {
        "nvim-treesitter/nvim-treesitter-context",
        dependencies = { "nvim-treesitter/nvim-treesitter-context" },
        event = "BufEnter",
        opts = {
            multiline_threshold = 20,
        },
        config = function(_, opts)
            require('treesitter-context').setup(opts)

            vim.keymap.set("n", "U", function()
                require("treesitter-context").go_to_context(vim.v.count1)
            end, { silent = true })
        end
    }
}
