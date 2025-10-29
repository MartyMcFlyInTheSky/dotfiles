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
    cmd = {'clangd', '-j=2', '--clang-tidy', '--log=verbose' },
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
        -- Formatting
        if client.supports_method("textDocument/formatting") then
            vim.keymap.set('n', 'gf', function()
                vim.lsp.buf.format({ bufnr = bufnr, id = client.id, timeout_ms = 1000 })
            end,
            { noremap = true, silent = true, buffer = bufnr })
        end
        -- Add 'go to definition'
        if client.supports_method("textDocument/definition") then
            vim.keymap.set("n", "gd", vim.lsp.buf.definition, { noremap = true, silent = true, buffer = bufnr })
        end
        -- Add 'go to declaration'
        if client.supports_method("textDocument/declaration") then
            vim.keymap.set("n", "gD", vim.lsp.buf.declaration, { noremap = true, silent = true, buffer = bufnr })
        end
        -- Add 'switch header/source'
        if client.supports_method("textDocument/switchSourceHeader") then
            vim.keymap.set("n", "gh", function()
                switch_source_header(bufnr, client)
            end,
            { noremap = true, silent = true, buffer = bufnr })
        end
        -- Display symbol info
        if client.supports_method('textDocument/symbolInfo') then
            vim.keymap.set("n", "gs", function()
                symbol_info(bufnr, client)
            end,
            { noremap = true, silent = true, buffer = bufnr })
        end
        -- Document symbols
        local ok, telescope_builtin = pcall(require, "telescope.builtin")
        if ok then
            vim.keymap.set("n", "gO", telescope_builtin.lsp_document_symbols, { noremap = true, silent = true, buffer = bufnr })
        else
            vim.print("was not ok")
        end
    -- Jump to declaration
    -- List all the implementations for the symbol under the cursor

        -- Switch header/source  
        -- Goto declaration
        -- 


        -- callback = function(args)
        --     local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
        --     if client:supports_method('textDocument/implementation') then
        --         -- Create a keymap for vim.lsp.buf.implementation ...
        --     end
        --     -- Enable auto-completion. Note: Use CTRL-Y to select an item. |complete_CTRL-Y|
        --     if client:supports_method('textDocument/completion') then
        --         -- Optional: trigger autocompletion on EVERY keypress. May be slow!
        --         -- local chars = {}; for i = 32, 126 do table.insert(chars, string.char(i)) end
        --         -- client.server_capabilities.completionProvider.triggerCharacters = chars
        --         vim.lsp.completion.enable(true, client.id, args.buf, {autotrigger = true})
        --     end
        --     -- Auto-format ("lint") on save.
        --     -- Usually not needed if server supports "textDocument/willSaveWaitUntil".
        --     if not client:supports_method('textDocument/willSaveWaitUntil')
        --         and client:supports_method('textDocument/formatting') then
        --         vim.api.nvim_create_autocmd('BufWritePre', {
        --             group = vim.api.nvim_create_augroup('my.lsp', {clear=false}),
        --             buffer = args.buf,
        --             callback = function()
        --                 vim.lsp.buf.format({ bufnr = args.buf, id = client.id, timeout_ms = 1000 })
        --             end,
        --         })
        --     end
        -- end,
        vim.api.nvim_buf_create_user_command(bufnr, 'LspClangdSwitchSourceHeader', function()
            switch_source_header(bufnr, client)
        end, { desc = 'Switch between source/header' })
        --
        -- vim.api.nvim_buf_create_user_command(bufnr, 'LspClangdShowSymbolInfo', function()
        --     symbol_info(bufnr, client)
        -- end, { desc = 'Show symbol info' })
    end,
}
