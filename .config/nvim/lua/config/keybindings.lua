-- Don't use nvim_set_keymap

-- (R)eplicate line
vim.keymap.set('n', 'R', "<CMD>t.<CR>", { noremap = true, silent = true })

-- (Y)ank to clipboard
vim.keymap.set('x', 'Y', '"+yy', { noremap = true, silent = true })

-- Open netrw
vim.keymap.set('n', '-', '<CMD>Ex<CR>', { noremap = true, silent = true })

-- Switch back and forth between buffers
vim.keymap.set('n', '<C-p>', '<CMD>bn<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<C-n>', '<CMD>bp<CR>', { noremap = true, silent = true })


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

-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"
