

-- Indentation --
-- (https://gist.github.com/LunarLambda/4c444238fb364509b72cfb891979f1dd)

-- On <Tab> indentation width is translated with blanks
vim.opt.expandtab = true
-- Set tab width to 4 blanks
vim.opt.tabstop = 4
-- On < and > and autoindent, how blanks to insert
vim.opt.shiftwidth = 0 -- use value of tabstop
-- How much to backspace
vim.opt.softtabstop = 4
-- Don't use shiftwidth at start of the line
vim.opt.smarttab = false


-- Disable smartindent if using treesitter indent (https://www.reddit.com/r/neovim/comments/14n6iiy/if_you_have_treesitter_make_sure_to_disable/)
-- Automatically indent after special chracters, e.g. braces {
vim.opt.smartindent = false
-- Auto-indent new lines
vim.opt.autoindent = true

-- Use winbar instead of statusbar
vim.opt.winbar = '%=%m %f %y'
vim.opt.laststatus = 0


-- -- require "nvchad.options"
-- 
-- -- local opt = vim.opt
-- local o = vim.opt
-- local g = vim.g
-- 
-- -------------------------------------- globals -----------------------------------------
-- 
-- g.mapleader = " "
-- g.toggle_theme_icon = "   "
-- 
-- -------------------------------------- options ------------------------------------------
-- 
-- -- Line numbers
vim.opt.nu = true
vim.opt.relativenumber = true
vim.opt.ruler = false
-- 
-- o.laststatus = 3
-- o.showmode = false
-- 
-- -- Indenting
-- o.expandtab = true
-- o.shiftwidth = 4
-- o.tabstop = 4
-- o.softtabstop = 4
-- o.smartindent = true
-- 
-- -- Cursorline
-- o.cursorline = true
-- o.cursorlineopt = "number"
-- 
-- -- Match pattern on all cases
-- o.smartcase = true
-- o.ignorecase = true
-- 
-- -- Enable overall mouse support
-- o.mouse = "a"
-- 
-- o.shortmess:append "sI"
-- 
-- -- Default splitting directions
-- o.splitbelow = true
-- o.splitright = true
-- 
-- -- Waiting for keystroke to complete
-- o.timeoutlen = 400
-- -- Interval for writing swapfile to disk, also used by gitsigns
-- o.updatetime = 250
-- o.swapfile = false
-- o.backup = false
-- 
-- -- Save undos in a file
-- o.undofile = true
-- 
-- -- Never wrap liens
-- o.wrap = false
-- 
-- -- Keep space below and above lines
-- o.scrolloff = 8
-- 
-- -- Signcolumn (for e.g. gitsigns)
-- o.signcolumn = "yes"
-- 
-- -- Search highlighting only when live typing
-- o.hlsearch = false
-- o.incsearch = true
-- 
-- -- Force enable 24 bit coloring
-- o.termguicolors = true
-- 
-- -- When opening another file with gf
-- o.isfname:append("@-@")
-- 
-- -- Mark col 80
-- o.colorcolumn = "80"
-- 
-- -- Add binaries installed by mason.nvim to path
-- local is_windows = vim.fn.has "win32" ~= 0
-- local sep = is_windows and "\\" or "/"
-- local delim = is_windows and ";" or ":"
-- v
