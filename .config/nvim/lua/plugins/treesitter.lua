return {
    {
        "nvim-treesitter/nvim-treesitter",
        dependencies = {
            "nvim-treesitter/nvim-treesitter-textobjects",
        },
        event = { "BufRead", "BufNewFile" },
        build = ":TSUpdate",
        config = function()
            local configs = require("nvim-treesitter.configs")

            configs.setup({
                ensure_installed = {
                    "c",
                    "cpp",
                    "lua",
                    "vim",
                    "vimdoc",
                    "query",
                    "elixir",
                    "heex",
                    "javascript",
                    "html",
                    "rust",
                    "toml",
                    "python",
                },
                sync_install = false,
                auto_install = true,
                highlight = {
                    enable = true,
                    additional_vim_regex_highlighting = false,
                },
                indent = {
                    enable = true,
                },
                rainbow = {
                    enable = true,
                    max_file_lines = 3000,
                },
                incremental_selection = {
                    enable = true,
                    keymaps = {
                        init_selection = "<C-space>",
                        node_incremental = "<C-space>",
                        scope_incremental = false,
                        node_decremental = "<bs>",
                    },
                },
            })
        end,
    },
    {
        -- https://www.josean.com/posts/nvim-treesitter-and-textobjects
        "nvim-treesitter/nvim-treesitter-textobjects",
        config = function()
            require("nvim-treesitter.configs").setup({
                textobjects = {
                    select = {
                        enable = true,
                        lookahead = true,
                        keymaps = {
                            -- You can use the capture groups defined in textobjects.scm
                            ["a="] = { query = "@assignment.outer", desc = "Select outer part of an assignment" },
                            ["i="] = { query = "@assignment.inner", desc = "Select inner part of an assignment" },
                            ["l="] = { query = "@assignment.lhs", desc = "Select left hand side of an assignment" },
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
                        swap = {
                            enable = true,
                            swap_next = {
                                ["<leader>na"] = "@parameter.inner", -- swap parameters/argument with next
                                ["<leader>nm"] = "@function.outer", -- swap function with next
                            },
                            swap_previous = {
                                ["<leader>pa"] = "@parameter.inner", -- swap parameters/argument with prev
                                ["<leader>pm"] = "@function.outer", -- swap function with previous
                            },
                        },
                        move = {
                            enable = true,
                            set_jumps = true, -- whether to set jumps in the jumplist (<C-i> and <C-o>)
                            goto_next_start = {
                                ["]f"] = { query = "@call.outer", desc = "Next function call start" },
                                ["]m"] = { query = "@function.outer", desc = "Next method/function def start" },
                                ["]c"] = { query = "@class.outer", desc = "Next class start" },
                                ["]i"] = { query = "@conditional.outer", desc = "Next conditional start" },
                                ["]l"] = { query = "@loop.outer", desc = "Next loop start" },

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
                            },
                            goto_previous_start = {
                                ["[f"] = { query = "@call.outer", desc = "Prev function call start" },
                                ["[m"] = { query = "@function.outer", desc = "Prev method/function def start" },
                                ["[c"] = { query = "@class.outer", desc = "Prev class start" },
                                ["[i"] = { query = "@conditional.outer", desc = "Prev conditional start" },
                                ["[l"] = { query = "@loop.outer", desc = "Prev loop start" },
                            },
                            goto_previous_end = {
                                ["[F"] = { query = "@call.outer", desc = "Prev function call end" },
                                ["[M"] = { query = "@function.outer", desc = "Prev method/function def end" },
                                ["[C"] = { query = "@class.outer", desc = "Prev class end" },
                                ["[I"] = { query = "@conditional.outer", desc = "Prev conditional end" },
                                ["[L"] = { query = "@loop.outer", desc = "Prev loop end" },
                            },
                        },
                    },
                },
            })
        end,
    },
}
