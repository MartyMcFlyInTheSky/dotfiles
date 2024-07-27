source $XDG_CONFIG_HOME/vim/vimrc
let &packpath = &runtimepath

" Redefine paths for nvim, e.g. viminfo is not compatible
let data_path = expand('$XDG_DATA_HOME') . '/nvim'
let config_path = expand('$XDG_CONFIG_HOME') . '/nvim'
let cache_path = expand('$XDG_CACHE_HOME') . '/nvim'
let state_path = expand('$XDG_STATE_HOME') . '/nvim'

" Set runtimepath to include the config_path and config_path/after
execute "set runtimepath^=" . config_path . "," . config_path . "/after," . data_path

" Set the directory for swap files
execute "set dir=" . data_path

" Set viminfo file location
execute "set viminfo=\'1000,n" . state_path . "/viminfo.shada"

" Set undo directory and enable undo file
if has("persistent_undo")
    let &undodir=data_path . '/undodir'
    set undofile
endif

lua require('config.lazy')
