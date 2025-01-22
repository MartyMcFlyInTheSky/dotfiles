return {
	{
		"nvim-telescope/telescope.nvim",
		tag = "0.1.8",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-telescope/telescope-ui-select.nvim",
			"nvim-telescope/telescope-dap.nvim",
			"lexay/telescope-zoxide.nvim",
		},
		opts = {
			defaults = {
				mappings = {
					-- Allow single esc close (https://www.reddit.com/r/neovim/comments/pzxw8h/telescope_quit_on_first_single_esc/)
					-- i = {
					-- 	["<esc>"] = function() require("telescope.actions").close() end,
					-- },
				},
			},
			extensions = {
				["ui-select"] = {
					function() require("telescope.themes").get_dropdown({}) end,
				},
			},
		},
		config = function(_, opts)
			local telescope = require("telescope")
			telescope.setup(opts)
			-- telescope.load_extension("ui-select")
			telescope.load_extension("zoxide")
			telescope.load_extension("dap")
		end,
		keys = {
			{ "<leader>fg", "<cmd>Telescope live_grep<cr>",  desc = "Live grep" },
			{ "<leader>fo", "<cmd>Telescope oldfiles<cr>",   desc = "List old files" },
			{ "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find files" },
			{ "<leader>fd", "<cmd>Telescope dap configurations<cr>", desc = "Get dap configurations" },
			{ "<leader>f?", "<cmd>Telescope help_tags<cr>", desc = "Explore help tags" },
			{ "<leader>fz", "<cmd>Telescope zoxide<cr>", desc = "Explore help tags" },
			{ "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "List open buffer" },

            -- LSP-specific
            { "<leader>fr", "<cmd>Telescope lsp_references<cr>", desc = "Show references for current token" },
            -- { "<leader>fi", "<cmd>Telescope lsp_incoming_calls<cr>", desc = "Show incoming calls" },
            -- { "<leader>fo", "<cmd>Telescope lsp_outgoing_calls<cr>", desc = "Show outgoing calls" },
		},
        cmd = { "Telescope"},
	},
}
