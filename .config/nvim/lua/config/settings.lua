-- Neovim specific settings
-- For settings shared with vim checkout $XDG_CONFIG_HOME/vim/vimrc

-- Use rounded borders for windows (since nvim 0.11)
vim.o.winborder = 'rounded'

-- Allow loading plugins also in headless mode
-- (important if we want to be able to access lua-json5 from outside)
vim.go.loadplugins = true

