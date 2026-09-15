return {
    dir = "~/dev_nvim/runrun.nvim",
    lazy = false,
    build = "sh build.sh",
    keys = {
        {
            "<leader>x",
            function()
                require("runrun.derive").cursor()
            end,
            desc = "RunRun derive cursor",
        },
    },
    config = function()
        local so_path = vim.fn.expand("~/dev_nvim/runrun.nvim/lua/runrun/picker_native.so")
        if not vim.uv.fs_stat(so_path) then
            vim.notify(
                "runrun.picker: build missing; run :Lazy build runrun.nvim and restart",
                vim.log.levels.WARN
            )
            return
        end

        local runrun = require("runrun.picker")
        runrun.setup({})
        -- runrun.open()
    end,
}
