return {
    {
        "github/copilot.vim",
        lazy = false,
    },
    {
        "CopilotC-Nvim/CopilotChat.nvim",
        dependencies = {
            { "github/copilot.vim" },              -- or zbirenbaum/copilot.lua
            { "nvim-lua/plenary.nvim", branch = "master" }, -- for curl, log and async functions
        },
        build = "make tiktoken",                   -- Only on MacOS or Linux
        opts = {
            -- See Configuration section for options
        },
        -- See Commands section for default commands if you want to lazy load on them
        keys = {
            { "<leader>e", ":CopilotChatExplain<CR>", mode = { "x", "n" }, {} },
            { "<leader>w", ":CopilotChatToggle<CR>", mode = { "x", "n" }, {} },
        },
    },
}
