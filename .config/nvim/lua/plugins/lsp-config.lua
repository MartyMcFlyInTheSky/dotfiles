return {
	{

		"williamboman/mason.nvim",
		opts = {},
	},
	{
		"williamboman/mason-lspconfig.nvim",
		dependencies = { "williamboman/mason.nvim" },
		opts = {
			ensure_installed = {
				"lua_ls",
				"bashls",
			},
		},
		lazy = false,
	},
	{
		"neovim/nvim-lspconfig",
		dependencies = { "williamboman/mason-lspconfig.nvim" },
		config = function()
			local lspconfig = require("lspconfig")
			lspconfig["lua_ls"].setup({})
			lspconfig["bashls"].setup({
				filetypes = { "sh", "bash" },
			})
		end,
		keys = {
			{ "K", vim.lsp.buf.hover, {} },
			{ "gd", vim.lsp.buf.definition, {} },
			{ "<leader>ca", vim.lsp.buf.code_action, {} },
		},
		lazy = false,
	},
}
