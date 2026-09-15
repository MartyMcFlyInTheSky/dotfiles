return {
  "obsidian-nvim/obsidian.nvim",
  version = "*",
  ft = "markdown",
  init = function()
    local vault = vim.fn.expand("~/.local/share/obsidian/daily_learnings")
    vim.api.nvim_create_autocmd({ "BufReadPre", "BufNewFile" }, {
      pattern = "*.md",
      callback = function(args)
        local path = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(args.buf), ":p")
        if path:sub(1, #vault + 1) == vault .. "/" then
          vim.opt_local.conceallevel = 2
        end
      end,
    })
  end,
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  opts = {
    legacy_commands = false,
    workspaces = {
      {
        name = "daily_learnings",
        path = vim.fn.expand("~/.local/share/obsidian/daily_learnings"),
      },
    },
    picker = {
      name = "telescope.nvim",
    },
  },
}
