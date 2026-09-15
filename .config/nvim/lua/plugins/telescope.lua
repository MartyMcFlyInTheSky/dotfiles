local function dap_configurations_picker(opts)
    opts = opts or {}

    local pickers = require "telescope.pickers"
    local finders = require "telescope.finders"
    local conf = require("telescope.config").values
    local actions = require "telescope.actions"
    local action_state = require "telescope.actions.state"
    local previewers = require "telescope.previewers"

    local dap = require("dap")

    local results = {}
    for lang, configs in pairs(dap.configurations) do
        if opts.language_filter == nil or opts.language_filter(lang) then
            for _, config in ipairs(configs) do
                table.insert(results, config)
            end
        end
    end

    local has_dap_plugin, dap_plugin = pcall(require, "dap-helpers")
    local curr_config = has_dap_plugin and dap_plugin.get_debug_config() or nil

    -- Find the previously selected option for potential reselection
    local curr_selection = 0
    for i, res in ipairs(results) do
        if res == curr_config then
            curr_selection = i
        end
    end

    -- Create a picker using defined variables
    pickers.new(opts, {
        prompt_title = "Dap Configuration",
        default_selection_index = curr_selection,
        finder = finders.new_table {
            results = results,
            entry_maker = function(entry)
                return {
                    value = entry,
                    display = entry.type .. ": " .. entry.name,
                    ordinal = entry.type .. ": " .. entry.name,
                    preview_command = function(entry, bufnr)
                        local output = vim.split(vim.inspect(entry.value), "\n")
                        vim.api.nvim_buf_set_lines(bufnr, 0, -1, true, output)
                    end,
                }
            end,
        },
        sorter = conf.generic_sorter(opts),
        attach_mappings = function(prompt_bufnr)
            actions.select_default:replace(function()
                local selection = action_state.get_selected_entry()
                actions.close(prompt_bufnr)

                -- Set debug configuration in the dap plugin module if available
                if has_dap_plugin then
                    dap_plugin.set_debug_config(selection.value)
                end
            end)

            return true
        end,
        previewer = previewers.display_content.new(opts)
    }):find()
end

return {
    "nvim-telescope/telescope.nvim",
    dependencies = {
        {
            'nvim-telescope/telescope-dap.nvim'
        },
        {
            "nvim-telescope/telescope-live-grep-args.nvim" ,
            -- This will not install any breaking changes.
            -- For major updates, this must be adjusted manually.
            version = "^1.0.0",
        },
    },
    requires = { { "nvim-lua/plenary.nvim" }, },
    config = function()
        local actions = require "telescope.actions"
        local telescope = require("telescope")
        local lga_actions = require("telescope-live-grep-args.actions")

        telescope.setup({
            defaults = {
                -- ~/.local/share/nvim/lazy/telescope.nvim/lua/telescope/mappings.lua
                mappings = {
                    i = {
                        ["<C-b>"] = actions.preview_scrolling_left,
                        ["<C-f>"] = actions.preview_scrolling_right,
                    }
                },
            },
            extensions = {
                live_grep_args = {
                    auto_quoting = true, -- enable/disable auto-quoting
                    -- define mappings, e.g.
                    mappings = { -- extend mappings
                        i = {
                            ["<C-t>"] = lga_actions.quote_prompt({ postfix = " --no-ignore --hidden" }),
                            ["<C-i>"] = lga_actions.quote_prompt({ postfix = " --iglob " }),
                            -- freeze the current list and start a fuzzy search in the frozen list
                            ["<C-space>"] = lga_actions.to_fuzzy_refine,
                        },
                    },
                    -- ... also accepts theme settings, for example:
                    -- theme = "dropdown", -- use dropdown theme
                    -- theme = { }, -- use own theme spec
                    -- layout_config = { mirror=true }, -- mirror preview pane
                }
            }
        })

        -- ts.load_extension("dap")
        telescope.load_extension("live_grep_args")
        telescope.extensions.dap.configurations = dap_configurations_picker
    end,
    -- Dap extensions
    keys = {
        -- vanilla
        { "<leader>ff", function() require('telescope.builtin').find_files() end, mode = { "n", "x" }, desc = "Find files" },
        { "<leader>fl", function() require('telescope.builtin').buffers({sort_mru=true, ignore_current_buffer=true}) end, mode = { "n", "x" }, desc = "Show last buffers" },
        { "<leader>r", function() require('telescope.builtin').resume() end, mode = { "n", "x" }, desc = "Resume last search" },
        { "<leader>p", function() require('telescope.builtin').commands() end, mode = { "n", "x" }, desc = "Open commands" },

        -- telescope-live-grep-args.actions
        { "<leader>g", function() require('telescope').extensions.live_grep_args.live_grep_args() end, mode = { "n", "x" }, desc = "Live grep with args" },

        -- telescope.dap
        { "<leader>dc", function() require('telescope').extensions.dap.configurations() end, mode = { "n", "x" }, desc = "Dap configurations" },
        { "<leader>b", function() require('telescope').extensions.dap.list_breakpoints() end, mode = { "n", "x" }, desc = "Dap breakpoints" },
        { "<leader>df", function() require('telescope').extensions.dap.frames() end, mode = { "n", "x" }, desc = "Dap frames" },

        -- LSP
        { "gO", function() require('telescope.builtin').lsp_document_symbols({ symbol_width = 60 }) end, mode = { 'n', 'x' }, { noremap = true }},
        { "<leader>i", function() require('telescope.builtin').lsp_incoming_calls() end, mode = { 'n', 'x' }, { noremap = true }},

        -- Grep word under cursor
        { "S", function()
            local word = vim.fn.expand("<cword>")
            require('telescope').extensions.live_grep_args.live_grep_args({
                default_text = word
            })
        end, mode = { "n" }, desc = "Grep word under cursor" },
    },
    lazy = false,
}
