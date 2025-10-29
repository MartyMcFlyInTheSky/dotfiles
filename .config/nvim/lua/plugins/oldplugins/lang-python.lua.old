return {
    {
        "mfussenegger/nvim-dap-python",
        ft = "python",
        dependencies = {
            "mfussenegger/nvim-dap",
        },
        config = function(_, opts)
            local path = "~/.local/share/nvim/mason/packages/debugpy/venv/bin/python"
            require("dap-python").setup(path)
        end,
    },
    {
        'linux-cultist/venv-selector.nvim',
        dependencies = {
            'neovim/nvim-lspconfig',
            'nvim-telescope/telescope.nvim',
            'mfussenegger/nvim-dap-python'
        },
        branch = "regexp",
        main = 'venv-selector',
        opts = {
            settings = {
                options = {
                    enable_default_searches = true,
                    set_environment_variables = true, -- sets VIRTUAL_ENV or CONDA_PREFIX environment variables
                },
                search = {
                    anaconda_base = {
                        command = "$FD '/python$' ~/anaconda3/envs --full-path --color never",
                        type = "anaconda",
                    },
                },
            },
            -- search_venv_managers = true,
            -- search = false,
            -- dap_enabled = true,
        },
        event = 'VeryLazy', -- Optional: needed only if you want to type `:VenvSelect` without a keymapping
        keys = {
            -- Keymap to open VenvSelector to pick a venv.
            { '<leader>vs', '<cmd>VenvSelect<cr>' },
            -- Keymap to retrieve the venv from a cache (the one previously used for the same project directory).
            { '<leader>vc', '<cmd>VenvSelectCached<cr>' },
        },
    }
}
