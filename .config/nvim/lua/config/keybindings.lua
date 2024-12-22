-- Use this instead of nvim_set_keymap
local map = vim.keymap.set

vim.api.nvim_set_keymap('n', '<Esc>k', ':t \'<-1<CR>V\'[', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<ESC>j', ':t \'>><CR>V\'[', { noremap = true, silent = true })


vim.api.nvim_set_keymap('x', '<Esc>K', ':t \'<-1<CR>V\'[', { noremap = true, silent = true })
vim.api.nvim_set_keymap('x', '<ESC>J', ':t \'>><CR>V\'[', { noremap = true, silent = true })


-- Move lines up / down
vim.keymap.set('n', '<ESC>k', "mz:m.-2<CR>`z", { noremap = true, silent = true })
vim.keymap.set('n', '<ESC>j', "mz:m.+1<CR>`z", { noremap = true, silent = true })

vim.keymap.set('v', '<ESC>k', ":m '<-2<CR>gv=gv", { noremap = true, silent = true })
vim.keymap.set('v', '<ESC>j', ":m '>+1<CR>gv=gv", { noremap = true, silent = true })

-- Copy lines up / down
vim.keymap.set('x', '<ESC>K', ":t '<-1<CR>V'[", { noremap = true, silent = true })
vim.keymap.set('x', '<ESC>J', ":t '><CR>V'[", { noremap = true, silent = true })

-- Yank to system selection clipboard
vim.keymap.set('x', '\033[99;6u', "\"+ygv", { noremap = true, silent = true })

-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"
