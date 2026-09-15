return {
    "NickvanDyke/opencode.nvim",
    dependencies = {
        -- Recommended for `ask()` and `select()`.
        -- Required for `snacks` provider.
        ---@module 'snacks' <- Loads `snacks.nvim` types for configuration intellisense.
        -- { "folke/snacks.nvim", opts = { input = {}, picker = {}, terminal = {} } },
    },
    config = function()
        ---@type opencode.Opts
        vim.g.opencode_opts = {
            -- Your configuration, if any — see `lua/opencode/config.lua`, or "goto definition" on the type or field.
            provider = {
                enabled = "wezterm",
                wezterm = {
                    direction = "right",
                    percent = 50,
                }
            },
            -- Don't launch a new instance, just fail with error
            launch = false,
        }


        -- Required for `opts.events.reload`.
        vim.o.autoread = true


        -- -- You may want these if you stick with the opinionated "<C-a>" and "<C-x>" above — otherwise consider "<leader>o…".
        -- vim.keymap.set("n", "+", "<C-a>", { desc = "Increment under cursor", noremap = true })
        -- vim.keymap.set("n", "-", "<C-x>", { desc = "Decrement under cursor", noremap = true })
    end,
    keys = {
        { "<leader>oa", function() require("opencode").ask("@this: ", { submit = true }) end, mode = { "n", "x" }, desc = "Ask opencode…" },
        { "<leader>ox", function() require("opencode").select() end, mode = { "n", "x" }, desc = "Execute opencode action…" },
        {"<C-S-u>", function() require("opencode").command("session.half.page.up") end, mode = {"n"}, desc = "Scroll opencode up" },
        {"<C-S-d>", function() require("opencode").command("session.half.page.down") end, mode = {"n"}, desc = "Scroll opencode down" },
    }
}
