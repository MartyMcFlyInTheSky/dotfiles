return {
	{
		"nvim-telescope/telescope.nvim",
		tag = "0.1.8",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-telescope/telescope-ui-select.nvim",
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
			telescope.load_extension("ui-select")
		end,
		keys = {
			{ "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Live grep" },
			{ "<leader>fo", "<cmd>Telescope oldfiles<cr>", desc = "List old files" },
			{ "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find files" },
		},
	},
}
