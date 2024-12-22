return {
  "catppuccin/nvim",
  name = "catppuccin",
  opts = {
    flavour = "moccha",    
    integrations = {
        alpha = true,
        aerial = true,
        dap = true,
        dap_ui = true,
        mason = true,
        neotree = true,
        notify = true,
        nvimtree = false,
        semantic_tokens = true,
        symbols_outline = true,
        telescope = true,
        ts_rainbow = false,
        which_key = true,
      },
  },
  specs = {
    {
      "akinsho/bufferline.nvim",
      optional = true,
      opts = function(_, opts)
        if (vim.g.colors_name or ""):find("catppuccin") then
          opts.highlights = require("catppuccin.groups.integrations.bufferline").get()
        end
      end,
    },
  },
  config = function()
      -- load the colorscheme here
      vim.cmd([[colorscheme catppuccin]])
    end,
    lazy = false,
  priority = 1000,
}
