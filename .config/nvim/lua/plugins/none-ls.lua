-- (https://www.reddit.com/r/neovim/comments/12er016/configuring_autoformatting_using_nullls_and/?tl=de)
return {
	"nvimtools/none-ls.nvim",
	opts = function()
		local null_ls = require("null-ls")
        -- https://github.com/nvimtools/none-ls.nvim/blob/main/doc/BUILTINS.md#formatting
		local formatting = null_ls.builtins.formatting
		return {
			sources = {
				formatting.stylua,
				formatting.isort,
				formatting.black,
				formatting.shfmt,
			},
		}
	end,
	keys = {
		{ "<leader>gf", vim.lsp.buf.format, {} },
	},
	lazy = false,
}
