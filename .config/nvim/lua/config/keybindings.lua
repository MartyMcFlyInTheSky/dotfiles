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


-- Emacs style keybindings for the command line (like bash)
-- Start of line
vim.api.nvim_set_keymap('c', '<C-A>', '<Home>', { noremap = true })
-- End of line
vim.api.nvim_set_keymap('c', '<C-E>', '<End>', { noremap = true })
-- Back one character
vim.api.nvim_set_keymap('c', '<C-B>', '<Left>', { noremap = true })
-- Delete character under cursor
vim.api.nvim_set_keymap('c', '<C-D>', '<Del>', { noremap = true })
-- Forward one character
vim.api.nvim_set_keymap('c', '<C-F>', '<Right>', { noremap = true })
-- Recall newer command-line
vim.api.nvim_set_keymap('c', '<C-N>', '<Down>', { noremap = true })
-- Recall previous (older) command-line
vim.api.nvim_set_keymap('c', '<C-P>', '<Up>', { noremap = true })
-- Back one word
vim.api.nvim_set_keymap('c', '<Esc><C-B>', '<S-Left>', { noremap = true })
-- Forward one word
vim.api.nvim_set_keymap('c', '<Esc><C-F>', '<S-Right>', { noremap = true })


-- Emacs style keybindings to supplement vim insert mode
-- Back one word
vim.api.nvim_set_keymap('i', '<C-B>', '<Left>', { noremap = true })
-- Forward one word
vim.api.nvim_set_keymap('i', '<C-F>', '<Right>', { noremap = true })
-- Start of line
vim.api.nvim_set_keymap('i', '<C-A>', '<Home>', { noremap = true })
-- End of line
vim.api.nvim_set_keymap('i', '<C-E>', '<End>', { noremap = true })
-- Kill forward
-- vim.api.nvim_set_keymap('i', '<C-K>', '<C-O>"+D', { noremap = true })
-- Kill backward
-- vim.api.nvim_set_keymap('i', '<C-U>', '<C-O>"+d0', { noremap = true })
-- vim.api.nvim_set_keymap('i', '<C-W>', '<C-O>"+dB', { noremap = true })
-- Yank
-- vim.api.nvim_set_keymap('i', '<C-Y>', '<C-O>"+P', { noremap = true })

-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"
