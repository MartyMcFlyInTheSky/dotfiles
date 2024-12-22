vim.api.nvim_create_user_command('K', function(opts)
    local pattern = opts.fargs[1]
    -- vim.cmd(string.format('\'<,\'>s/%s\\(\\s*$\\)\\@!/&\\r/g', pattern))
    vim.cmd(string.format('s/%s\\(\\s*$\\)\\@!/&\\r/g', pattern))
end, { nargs = 1, range = '%' })
