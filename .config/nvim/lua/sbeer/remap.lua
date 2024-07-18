vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)

-- Move current line or selected block of lines up
vim.keymap.set('v', '<M-k>', "mz:m '<-2<CR>gv=gv`z", { noremap = true, silent = true })
vim.keymap.set('n', '<M-k>', 'mz:m .-2<CR>`z', { noremap = true, silent = true })
-- Move current line or selected block of lines down
vim.keymap.set('v', '<M-j>', "mz:m '>+1<CR>gv=gv`z", { noremap = true, silent = true })
vim.keymap.set('n', '<M-j>', 'mz:m .+1<CR>`z', { noremap = true, silent = true })

vim.keymap.set('n', "J", "mzJ`z")
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")

vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- Allow keeping the pasted word in the register
vim.keymap.set("x", "<leader>p", "\"_dP")

-- This doesn't work somehow, TODO: fixit
vim.keymap.set("n", "<leader>y", "\"+y")
vim.keymap.set("v", "<leader>Y", "\"+y")
vim.keymap.set("n", "<leader>Y", "\"+Y")

-- disable legacy Ex command mode
vim.keymap.set("n", "Q", "<nop>")

-- vim.keymap.set("n", "<C-f>", "<cmd>silent !tmux neww tmux-sessionizer.sh<CR>")
vim.keymap.set("n", "<C-f>", "<cmd>silent !tmux neww tmux-sessionizer.sh<CR>")

vim.keymap.set("n", "<C-k>", "<cmd>cnext<CR>zz")
vim.keymap.set("n", "<C-j>", "<cmd>cprev<CR>zz")
vim.keymap.set("n", "<leader>k", "<cmd>lnext<CR>zz")
vim.keymap.set("n", "<leader>j", "<cmd>lprev<CR>zz")

vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])
vim.keymap.set("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = true })
