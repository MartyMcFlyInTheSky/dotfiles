" Set the leader key
let mapleader=" "


if !has('nvim')
    " Enable OSCyank
    nmap "+y  <Plug>OSCYankOperator
    nmap "+yy <Plug>OSCYankOperator_
    vmap "+y <Plug>OSCYankVisual
endif


" Find also {} on function header lines
map [[ ?{<CR>w99[{
map ][ /}<CR>b99]}
map ]] j0[[%/{<CR>
map [] k$][%?}<CR>

" Move current line or selected block of lines up
vnoremap <A-k> mz:m '<-2<CR>gv=gv`z
nnoremap <A-k> mz:m .-2<CR>`z

" Move current line or selected block of lines down
vnoremap <A-j> mz:m '>+1<CR>gv=gv`z
nnoremap <A-j> mz:m .+1<CR>`z

" Copy current selection up or down
nnoremap <A-S-K> :t .-1<CR>==
nnoremap <A-S-J> :t .<CR>==
xnoremap <A-S-K> :t '<-1<CR>V'[
xnoremap <A-S-J> :t '><CR>V'[

" Search for word under cursor
nnoremap g/ /<C-r><C-w>

" Quick quickfix navigation
nnoremap <C-p> :cprev<CR>
nnoremap <C-n> :cnext<CR>

" Ctrl+s / Ctrl+q (XON/XOFF) need to be deactivated in bash
function! ToggleQuickfix() abort
  " Check if a quickfix window is already open
  for win in range(1, winnr('$'))
    if getwinvar(win, '&buftype') ==# 'quickfix'
      cclose
      return
    endif
  endfor
  copen
endfunction

nnoremap <silent> <C-q> :call ToggleQuickfix()<CR>

" Previous and next quickfix list
nnoremap <C-f> :cnewer<CR>
nnoremap <C-b> :colder<CR>

" Select windows with C-hjkl
nnoremap <C-h> <C-w>h
" nnoremap <C-j> :call FocusDown()<CR>
" nnoremap <C-k> :call FocusUp()<CR>
nnoremap <C-l> <C-w>l

" Split windows
nnoremap <silent> <esc>[1;6l :call MergeOrSplitRight()<CR>
" nnoremap <leader>j :belowright sp<CR>
" nnoremap <leader>k :leftabove sp<CR>
nnoremap <silent> <esc>[1;6h :call MergeOrSplitLeft()<CR>

" Resizing windows
" nnoremap <S-h> :vertical res +5<CR>
" nnoremap <S-j> :res +5<CR>
" nnoremap <S-k> :res -5<CR>
" nnoremap <S-l> :vertical res -5<CR>

" Move to the next line and join lines, keeping cursor position
nnoremap J mzJ`z

" Center screen after scrolling half page down
nnoremap <C-d> <C-d>zz

" Turn last word to uppercase
inoremap <C-u> <esc>vbUea

" Center screen after searching next
nnoremap n nzzzv

" Center screen after searching previous
nnoremap N Nzzzv

" Leader keybinds

" Improved find command search and wildmenu

" Define fallback for git
let toplevel = expand('~')
let gitdir = expand('~/.myconfig')

let &path = '.,,'
let &wildignore = 'LICENSE'

" join(systmelist('git ls-tree -d --name-only -r HEAD'), ',')


" augroup PATH_AND_WILDIGNORE
"   autocmd!
"   autocmd BufReadPost,BufNewFile *
"         \ if !empty(FugitiveGitDir()) |
"         \   Glcd |
"         \   let &l:path       = &g:path . join(systemlist('git ls-tree -d --name-only -r HEAD'), ',') |
"         \   let &l:wildignore = (empty(&wildignore) ? '' : &wildignore..',') .. escape(join(systemlist('git check-ignore **/.* **/*'), ','), '{}\')
"         \ endif
" augroup END

" Allow keeping the pasted word in the register
" xnoremap <leader>p "_dP

" Yank to the system clipboard (normal mode)
nnoremap <leader>y "+y

" Yank to the system clipboard (visual mode)
vnoremap <leader>Y "+y

" Yank to the system clipboard (normal mode, entire line)
nnoremap <leader>Y "+Y

" Disable legacy Ex command mode
nnoremap Q <nop>

" Substitute the word under cursor
"nnoremap <leader>s :%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>

" Make the current file executable
"nnoremap <leader>x :!chmod +x %<CR>

" Sessionizer
nnoremap <C-s> <Cmd>SaveSessionAndQuit<CR>

" Move back and forth between args
nnoremap <C-f> <CMD>next<CR>
nnoremap <C-b> <CMD>prev<CR>

" Toggle word wrap
nnoremap <A-z> <CMD>set wrap!<CR>

" Quick save
nnoremap <leader>w <CMD>w<CR>

" Source current
nnoremap <leader>x <CMD>so %<CR>
