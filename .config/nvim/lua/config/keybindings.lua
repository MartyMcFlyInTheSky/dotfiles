-- Don't use nvim_set_keymap

-- (Y)ank to clipboard
vim.keymap.set({ 'x', 'n' }, 'Y', '"+yy', { noremap = true, silent = true })

-- Quickfix list controls

local toggle_qf = function()
    local qf_exists = false
    for _, win in pairs(vim.fn.getwininfo()) do
        if win["quickfix"] == 1 then
            qf_exists = true
        end
    end
    if qf_exists == true then
        vim.cmd("cclose")
        return
    end
    if not vim.tbl_isempty(vim.fn.getqflist()) then
        vim.cmd "copen"
    end
end

vim.keymap.set('n', '<C-p>', '<CMD>cp<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<C-n>', '<CMD>cn<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<C-q>', toggle_qf, { noremap = true, silent = true })

vim.api.nvim_set_keymap('n', '<Esc>k', ':t \'<-1<CR>V\'[', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<ESC>j', ':t \'>><CR>V\'[', { noremap = true, silent = true })


vim.api.nvim_set_keymap('x', '<Esc>K', ':t \'<-1<CR>V\'[', { noremap = true, silent = true })
vim.api.nvim_set_keymap('x', '<ESC>J', ':t \'>><CR>V\'[', { noremap = true, silent = true })

-- Move lines up / down
vim.keymap.set('n', '<A-k>', "mz:m.-2<CR>`z", { noremap = true, silent = true })
vim.keymap.set('n', '<A-j>', "mz:m.+1<CR>`z", { noremap = true, silent = true })
vim.keymap.set('x', '<A-k>', ":m '<-2<CR>gv=gv", { noremap = true, silent = true })
vim.keymap.set('x', '<A-j>', ":m '>+1<CR>gv=gv", { noremap = true, silent = true })

-- Copy lines up / down
vim.keymap.set('n', '<A-K>', ":t .-1<CR>", { noremap = true, silent = true })
vim.keymap.set('n', '<A-J>', ":t .<CR>", { noremap = true, silent = true })
vim.keymap.set('x', '<A-K>', ":t '<-1<CR>V'[", { noremap = true, silent = true })
vim.keymap.set('x', '<A-J>', ":t '><CR>V'[", { noremap = true, silent = true })

-- Toggle word wrapp
vim.keymap.set({ 'x', 'n' }, '<A-z>', function() vim.o.wrap = not vim.o.wrap end, { noremap = true, silent = true })

-- Execute current file
vim.keymap.set({ 'x', 'n' }, '<leader><leader>x', "<cmd>w<CR><cmd>source %<CR>")

-- vim.keymap.set('n', '<ESC>j', '<CMD>echo "Hello escape!"<CR>', { noremap = true, silent = true })

-- Readline style keybindings
local config_home = os.getenv('XDG_CONFIG_HOME') or '~/.config'

-- Specify the path to your vimrc or init.lua file
local vimkeys_path = config_home .. '/vim/readline_keys.vim'

-- Source the file if it exists
if vim.fn.filereadable(vimkeys_path) == 1 then
    vim.cmd('source ' .. vimkeys_path)
else
    print('File not found: ' .. vimkeys_path)
end
-- Use this instead of nvim_set_keymap
local map = vim.keymap.set


-- Yank to system selection clipboard
vim.keymap.set('x', '\033[99;6u', "\"+ygv", { noremap = true, silent = true })

-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"
