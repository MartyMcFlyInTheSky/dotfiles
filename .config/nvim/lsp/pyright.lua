
local function set_python_path(command)
    local path = command.args
    for _, client in ipairs(vim.lsp.get_clients({ name = "pyright" })) do
        -- merge into the client’s config settings (this is the correct field)
        client.config.settings = vim.tbl_deep_extend(
            'force',
            client.config.settings or {},
            { python = { pythonPath = path } }  -- or see “Note on pyright” below
        )

        -- notify the server that settings changed
        client:notify('workspace/didChangeConfiguration', {
            settings = client.config.settings,
        })
        vim.print("told server to set path to " .. path)
    end
end

return {
    cmd = { "pyright-langserver", "--stdio" },
    root_markers = { { "pyproject.toml", "setup.py", "setup.cfg", "requirements.txt", "Pipfile", "pyrightconfig.json" }, ".git" },
    filetypes = { 'python' },
    settings = {
        python = {
            analysis = {
                autoSearchPaths = true,
                diagnosticMode = "openFilesOnly",
                useLibraryCodeForTypes = true
            }
        }
    },
    on_attach = function(client, bufnr)
        vim.api.nvim_buf_create_user_command(bufnr, 'LspPyrightOrganizeImports', function()
            local params = {
                command = 'pyright.organizeimports',
                arguments = { vim.uri_from_bufnr(bufnr) },
            }

            -- Using client.request() directly because "pyright.organizeimports" is private
            -- (not advertised via capabilities), which client:exec_cmd() refuses to call.
            -- https://github.com/neovim/neovim/blob/c333d64663d3b6e0dd9aa440e433d346af4a3d81/runtime/lua/vim/lsp/client.lua#L1024-L1030
            client.request('workspace/executeCommand', params, nil, bufnr)
        end, {
                desc = 'Organize Imports',
            })
        vim.api.nvim_buf_create_user_command(bufnr, 'LspPyrightSetPythonPath', set_python_path, {
            desc = 'Reconfigure pyright with the provided python path',
            nargs = 1,
            complete = 'file',
        })
    end,
}
