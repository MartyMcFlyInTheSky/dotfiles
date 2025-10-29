-- TODO
-- display red statusline when file being edited is outside of workspace directory
-- open line on gitlab
--
--
-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)

-- write something to a file so we know that headless still reads this

local file = "/home/sbeer/tmp/mystats.txt"
vim.fn.writefile({ "Hello" }, file)

-- Load old Vimscript config
-- local home = vim.loop.os_homedir()
-- local xdg_config_home = vim.env.XDG_CONFIG_HOME or (home .. '/.config')

local vimrc = vim.fn.stdpath('config') .. "/../vim/vimrc"
if vim.fn.filereadable(vimrc) == 1 then
    vim.cmd("source " .. vimrc)
end

vim.go.loadplugins = true
require("config.settings")
require("config.lazy")
require("config.keybindings")
require("launcher")
-- require("config.cmds")
-- require("globals")
-- Enable lsp clients by default
--
--
-- Base config (merged with lsp/<config>.lua files)
vim.lsp.config('*', {
  capabilities = {
    textDocument = {
      semanticTokens = {
        multilineTokenSupport = true,
      }
    }
  },
  root_markers = { '.git' },
})
vim.lsp.enable({
    'clangd',
    'lua_ls',
    'pyright',
    'bashls',
    'gopls',
})

-- Add dylib to package cpath as suggested [here](https://github.com/Joakker/lua-json5)
package.cpath = package.cpath .. ';?.dylib'


--=============================================================================
--  Setup DAP directory
--=============================================================================

-- Make modules in dap_dir discoverable by `require`
dap_dir = vim.fn.fnamemodify(vim.fn.expand("$MYVIMRC"), ":h") .. "/dap" 
require('dap-helpers').setup({
    dap_dir = dap_dir
})


-- Prevent LSP from overwriting treesitter color settings
-- https://github.com/NvChad/NvChad/issues/1907
--vim.hl.priorities.semantic_tokens = 95 -- Or any number lower than 100, treesitter's priority level

--=============================================================================
--  Configure diagnostics-api
--=============================================================================

vim.diagnostic.config {
  virtual_text = {
    prefix = '●',
    -- Add a custom format function to show error codes
    format = function(diagnostic)
      local code = diagnostic.code and string.format('[%s]', diagnostic.code) or ''
      return string.format('%s %s', code, diagnostic.message)
    end,
  },
  underline = false,
  update_in_insert = true,
  float = {
    source = true, -- Or "if_many"
  },
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = ' ',
      [vim.diagnostic.severity.WARN] = ' ',
      [vim.diagnostic.severity.INFO] = ' ',
      [vim.diagnostic.severity.HINT] = '󰌵 ',
    },
  },
  -- Make diagnostic background transparent
  on_ready = function()
    vim.cmd 'highlight DiagnosticVirtualText guibg=NONE'
  end,
}

vim.keymap.set("n", "gl", vim.diagnostic.open_float, { noremap = true, silent = true, buffer = bufnr })




