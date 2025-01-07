" Set the leader key
let mapleader=" "

nnoremap <leader>pv :Ex<CR>

" Find also {} on function header lines
map [[ ?{<CR>w99[{
map ][ /}<CR>b99]}
map ]] j0[[%/{<CR>
map [] k$][%?}<CR>

" Move current line or selected block of lines up
vnoremap <ESC>k mz:m '<-2<CR>gv=gv`z
nnoremap <ESC>k mz:m .-2<CR>`z

" Move current line or selected block of lines down
vnoremap <ESC>j mz:m '>+1<CR>gv=gv`z
nnoremap <ESC>j mz:m .+1<CR>`z

" Copy current selection up or down
nnoremap <ESC>K :t .-1<CR>==
nnoremap <ESC>J :t .<CR>==
xnoremap <Esc>K :t '<-1<CR>V'[
xnoremap <ESC>J :t '><CR>V'[

" Remap <C-i> which is Tab to cycle through buffer
nnoremap <C-n> <TAB>
nnoremap <TAB> :bnext<CR>
nnoremap <C-TAB> :bprev<CR>


" Select windows with C-hjkl
nnoremap <C-h> :wincmd h<CR>
nnoremap <C-j> :wincmd j<CR>
nnoremap <C-k> :wincmd k<CR>
nnoremap <C-l> :wincmd l<CR>

" Split windows
nnoremap <leader>h :leftabove vsp<CR>
nnoremap <leader>j :belowright sp<CR>
nnoremap <leader>k :leftabove sp<CR>
nnoremap <leader>l :belowright vsp<CR>

" Resizing windows
nnoremap <S-h> :vertical res +5<CR>
nnoremap <S-j> :res +5<CR>
nnoremap <S-k> :res -5<CR>
nnoremap <S-l> :vertical res -5<CR>

" Move to the next line and join lines, keeping cursor position
nnoremap J mzJ`z

" Center screen after scrolling half page down
nnoremap <C-d> <C-d>zz

" Center screen after scrolling half page up
nnoremap <C-u> <C-u>zz

" Center screen after searching next
nnoremap n nzzzv

" Center screen after searching previous
nnoremap N Nzzzv

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

" Open a new tmux window and run tmux-sessionizer.sh
nnoremap <C-f> :terminal tmux-sessionizer.sh<CR>

" Navigate to the next location list entry and center screen
" nnoremap <leader>k :lnext<CR>zz

" Navigate to the previous location list entry and center screen
" nnoremap <leader>j :lprev<CR>zz

" Substitute the word under cursor
nnoremap <leader>s :%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>

" Make the current file executable
nnoremap <leader>x :!chmod +x %<CR>

" Include readline style keymappings
source $XDG_CONFIG_HOME/vim/readline_keys.vim

