-- (https://www.reddit.com/r/neovim/comments/12er016/configuring_autoformatting_using_nullls_and/?tl=de)
return {
    "nvimtools/none-ls.nvim",
    opts = function()
        local null_ls = require("null-ls")
        -- https://github.com/nvimtools/none-ls.nvim/blob/main/doc/BUILTINS.md#formatting
        local formatting = null_ls.builtins.formatting
        local diagnostics = null_ls.builtins.diagnostics
        return {
            sources = {
                formatting.stylua,
                formatting.isort,
                formatting.black,
                formatting.shfmt,
                diagnostics.mypy,
            },
            on_attach = function(client, bufnr)
                if client.supports_method("textDocument/formatting") then
                    vim.api.nvim_clear_autocmds({
                        group = augroup,
                        buffer = bufnr,
                    })
                    vim.api.nvim_create_autocmd("BufWritePre", {
                        group = augroup,
                        buffer = bufnr,
                        callback = function()
                            vim.lsp.buf.format({bufnr = bufnr })
                        end,
                    })
                end
            end,
        }
    end,
    keys = {
        { "<leader>gf", vim.lsp.buf.format, {} },
    },
    lazy = false,
}
