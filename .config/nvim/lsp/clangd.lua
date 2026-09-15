-- nvim-help: https://neovim.io/doc/user/lsp.html#lsp-quickstart
-- nvim-lspconfig: https://github.com/neovim/nvim-lspconfig/blob/master/lsp/clangd.lua


-- https://clangd.llvm.org/extensions.html#switch-between-sourceheader
local function switch_source_header(bufnr, client)
  ---@diagnostic disable-next-line:param-type-mismatch
  local params = vim.lsp.util.make_text_document_params(bufnr)
  ---@diagnostic disable-next-line:param-type-mismatch
  client:request('textDocument/switchSourceHeader', params, function(err, result)
    if err then
      error(tostring(err))
    end
    if not result then
      vim.notify('Corresponding file cannot be determined')
      return
    end
    vim.cmd.edit(vim.uri_to_fname(result))
  end, bufnr)
end


local function symbol_info(bufnr, client)
  local win = vim.api.nvim_get_current_win()
  local params = vim.lsp.util.make_position_params(win, client.offset_encoding)
  ---@diagnostic disable-next-line:param-type-mismatch
  client:request('textDocument/symbolInfo', params, function(err, res)
    if err or #res == 0 then
      -- Clangd always returns an error, there is no reason to parse it
      return
    end
    local container = string.format('container: %s', res[1].containerName) ---@type string
    local name = string.format('name: %s', res[1].name) ---@type string
    vim.lsp.util.open_floating_preview({ name, container }, '', {
      height = 2,
      width = math.max(string.len(name), string.len(container)),
      focusable = false,
      focus = false,
      title = 'Symbol Info',
    })
  end, bufnr)
end

return {
    -- global clangd instance is configured in ~/.config/clangd/config.yaml
    cmd = {'clangd', '-j', '2', '--clang-tidy', '--log=verbose' },
    -- Root markers, .git folder is always a fallback
    root_markers = { '.vscode' },
    -- root_markers = { {
    --     '.clangd',
    --     '.clang-tidy',
    --     '.clang-format',
    --     'compile_commands.json',
    --     'compile_flags.txt',
    --     'configure.ac', -- AutoTools
    -- }, '.git'
    -- },
    capabilities = {
        textDocument = {
            completion = {
                editsNearCursor = true,
            },
        },
        offsetEncoding = { 'utf-8', 'utf-16' },
    },
    filetypes = { 'c', 'cpp', 'objc', 'objcpp', 'cuda' },
    on_init = function(client, init_result)
        if init_result.offsetEncoding then
            client.offset_encoding = init_result.offsetEncoding
        end
    end,
    on_attach = function(client, bufnr)
        local function map(lhs, rhs, desc)
            vim.keymap.set("n", lhs, rhs, { buffer = bufnr, silent = true, noremap = true, desc = desc })
        end

        -- Switch header/source
        if client:supports_method("textDocument/switchSourceHeader") then
            map("gh", function()
                switch_source_header(bufnr, client)
            end, "LSP: Switch header/source")
        end

        -- Symbol info
        if client:supports_method("textDocument/symbolInfo") then
            map("gs", function()
                symbol_info(bufnr, client)
            end, "LSP: Symbol info")
        end
    end,
}
