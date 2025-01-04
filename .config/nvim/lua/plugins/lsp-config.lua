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
                -- temporarily disabled because of Invalid line col error (https://github.com/rust-lang/rust-analyzer/issues/17289)
				"rust_analyzer",
			},
		},
		lazy = false,
	},
	{
		"neovim/nvim-lspconfig",
		dependencies = { "williamboman/mason-lspconfig.nvim" },
		config = function()
            local capabilities = require('cmp_nvim_lsp').default_capabilities()

			local lspconfig = require("lspconfig")
			lspconfig["lua_ls"].setup({
                capabilities = capabilities,
            })
			lspconfig["bashls"].setup({
				filetypes = { "sh", "bash" },
                capabilities = capabilities,
			})
            lspconfig["rust_analyzer"].setup({
                root_dir = lspconfig.util.root_pattern("Cargo.toml"),
                filetypes = { "rust" },
                settings = {
                    ["rust-analyzer"] = {
                        cargo = {
                            allFeatures = true,
                        },
                    },
                },
            })
		end,
		keys = {
			{ "K", vim.lsp.buf.hover, {} },
			{ "gd", vim.lsp.buf.definition, {} },
			{ "<leader>ca", vim.lsp.buf.code_action, {} },
		},
		lazy = false,
	},
    -- Rust specific
    {
        "rust-lang/rust.vim",
        ft = "rust",
        init = function()
            vim.g.rustfmt_autosave = 1
        end,
    },
}
