-- Additional telescope pickers

local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local conf = require("telescope.config").values
local actions      = require'telescope.actions'
local action_state = require'telescope.actions.state'
local previewers   = require'telescope.previewers'


local has_dap, dap = pcall(require, 'dap')
if not has_dap then
  error('This plugins requires mfussenegger/nvim-dap')
end


-- Pick configurations
local configurations = function(opts)
    opts = opts or {}

    local results = {}
    for lang, configs in pairs(dap.configurations) do
        if opts.language_filter == nil or opts.language_filter(lang) then
            for _, config in ipairs(configs) do
                table.insert(results, config)
            end
        end
    end

    local has_dap_plugin, dap_plugin = pcall(require, 'dap-helpers')
    local curr_config = dap_plugin.get_debug_config()

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
                    display = entry.type .. ': ' .. entry.name,
                    ordinal = entry.type .. ': ' .. entry.name,
                    preview_command = function(entry, bufnr)
                        local output = vim.split(vim.inspect(entry.value), '\n')
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
        -- { 'nvim-telescope/telescope-dap.nvim' },
        {
            "nvim-telescope/telescope-live-grep-args.nvim" ,
            -- This will not install any breaking changes.
            -- For major updates, this must be adjusted manually.
            version = "^1.0.0",
        },
    },
    requires = { { "nvim-lua/plenary.nvim" }, },
    config = function()
        local telescope = require('telescope')
        local lga_actions = require("telescope-live-grep-args.actions")

        telescope.setup({
            extensions = {
                live_grep_args = {
                    auto_quoting = true, -- enable/disable auto-quoting
                    -- define mappings, e.g.
                    mappings = { -- extend mappings
                        i = {
                            ["<C-t>"] = lga_actions.quote_prompt(),
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
    end,
    -- Dap extensions
    keys = {
        -- { "<leader>d", function() configurations() end, mode = "n", desc = "Debugger continue" },
        -- { "<leader>t", function() tasks() end, mode = "n", desc = "Debugger continue" },
        { "<leader>f", function() require('telescope.builtin').git_files() end, mode = "n", desc = "Find files" },
        { "<leader>g", function() require('telescope').extensions.live_grep_args.live_grep_args() end, mode = "n", desc = "Live grep with args" },
    },
    lazy = false,
}
