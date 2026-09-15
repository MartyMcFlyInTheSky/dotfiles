return {
    "open-on-remote.nvim",
    dev = true,
    lazy = false,
    keys = {
        { "<C-.>", function() require("open-on-remote").copy_local_ref() end, mode = { "n", "x" }, desc = "Copy local ref" },
        { "<C-,>", function() require("open-on-remote").open_remote_url() end, mode = { "n", "x" }, desc = "Open remote URL" },
    },
    config = function()
        require("open-on-remote").setup({
            worktrees = {
                {
                    toplevel = vim.env.HOME,
                    gitdir = vim.env.HOME .. "/.myconfig"
                }
            }
        })
    end,
}
