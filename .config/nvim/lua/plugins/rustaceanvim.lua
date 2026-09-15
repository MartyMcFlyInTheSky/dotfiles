
local function reload_workspace(bufnr)
  local clients = vim.lsp.get_clients { bufnr = bufnr, name = 'rust_analyzer' }
  for _, client in ipairs(clients) do
    vim.notify 'Reloading Cargo Workspace'
    ---@diagnostic disable-next-line:param-type-mismatch
    client:request('rust-analyzer/reloadWorkspace', nil, function(err)
      if err then
        error(tostring(err))
      end
      vim.notify 'Cargo workspace reloaded'
    end, 0)
  end
end

-- vim.print("vim.g.loaded_rustaceanvim check in config = " .. vim.inspect(vim.g.loaded_rustaceanvim))
vim.g.rustaceanvim = function()
    return {
        -- LSP configuration
        server = {
            on_attach = function(client, bufnr)
                -- you can also put keymaps in here
                -- supports rust-analyzer's grouping
                -- or vim.lsp.buf.codeAction() if you don't want grouping.
                vim.keymap.set( "n", "gra", function() vim.cmd.RustLsp('codeAction')
                    end, { silent = true, buffer = bufnr })
                -- Override Neovim's built-in hover keymap with rustaceanvim's hover actions
                vim.keymap.set( "n", "K", function() vim.cmd.RustLsp({ 'hover', 'actions' }) end,
                    { silent = true, buffer = bufnr })
                -- Copied this from nvim.lspconfig, not sure if it's anymore useful
                vim.api.nvim_buf_create_user_command(bufnr, 'LspCargoReload', function()
                    reload_workspace(bufnr)
                end, { desc = 'Reload current cargo workspace' })
            end,
            default_settings = {
                -- rust-analyzer language server configuration
                ['rust-analyzer'] = {
                    cargo = {
                        allTargets = true,
                    },
                },
            },
            status_notify_level = "warning",
        },
        dap = {
            adapter = function()
                local dap = require("dap")
                if not dap.adapters.codelldb then
                    require("dap.loader").setup(dap)
                end
                return dap.adapters.codelldb
            end,
            configuration = function()
                return {
                    type = "codelldb",
                    name = "Rust debug",
                    request = "launch",
                    sourceLanguages = { "rust" },
                }
            end,
        },
    }
end

return {
    {
        'mrcjkb/rustaceanvim',
        dependencies = {
            "mfussenegger/nvim-dap",
        },
        version = '^6', -- Recommended
        lazy = false, -- This plugin is already lazy
    }
}
