" rsi.vim - Readline style insertion
" Maintainer:   Tim Pope
" Version:      1.0
" GetLatestVimScripts: 4359 1 :AutoInstall: rsi.vim


" Wait 50 milliseconds for keys after escape sequence.
set ttimeout
if &ttimeoutlen == -1
  set ttimeoutlen=50
endif


function! s:ctrl_u()
  if getcmdpos() > 1
    let @- = getcmdline()[:getcmdpos()-2]
  endif
  return "\<C-U>"
endfunction


function! s:transpose() abort
  let pos = getcmdpos()
  if getcmdtype() =~# '[?/]'
    return "\<C-T>"
  elseif pos > strlen(getcmdline())
    let pre = "\<Left>"
    let pos -= 1
  elseif pos <= 1
    let pre = "\<Right>"
    let pos += 1
  else
    let pre = ""
  endif
  return pre . "\<BS>\<Right>".matchstr(getcmdline()[0 : pos-2], '.$')
endfunction


" Jump to beginning and end of line
inoremap        <C-A> <C-O>^
inoremap   <C-X><C-A> <C-A>
cnoremap        <C-A> <Home>
cnoremap   <C-X><C-A> <C-A>

inoremap <expr> <C-E> col('.') > strlen(getline('.'))<bar><bar>pumvisible() ? "\<Lt>C-E>":"\<Lt>End>"
" <C-E> is already mapped in command-line mode


" Move forward and backward by character
inoremap <expr> <C-B> getline('.')=~'^\s*$' && col('.')>strlen(getline('.')) ? "0\<Lt>C-D>\<Lt>Esc>kJs":"\<Lt>Left>"
cnoremap        <C-B> <Left>

inoremap <expr> <C-F> col('.') > strlen(getline('.')) ? "\<Lt>C-F>":"\<Lt>Right>"
cnoremap <expr> <C-F> getcmdpos() > strlen(getcmdline()) ? &cedit:"\<Lt>Right>"

" Delete character under cursor
" inoremap <expr> <C-D> col('.') > strlen(getline('.')) ? "\<Lt>C-D>":"\<Lt>Del>"
cnoremap <expr> <C-D> getcmdpos() > strlen(getcmdline()) ? "\<Lt>C-D>":"\<Lt>Del>"

" Delete character before cursor
" <C-H> is already mapped in both modes

" Kill to beginning of line
cnoremap <expr> <C-U> <SID>ctrl_u()
" <C-U> is already mapped in insert mode

" Kill to end of line
" <C-K> is already mapped in both modes

" Yank
cnoremap <expr> <C-Y> pumvisible() ? "\<C-Y>" : "\<C-R>-"
" inoremap        <C-Y> <C-R>-

" Transpose characters
cnoremap <expr> <C-T> <SID>transpose()
" <C-T> is mapped to indenting this line already

if exists('g:rsi_no_meta')
  finish
endif

if &encoding ==# 'latin1' && has('gui_running') && !empty(findfile('plugin/sensible.vim', escape(&rtp, ' ')))
  set encoding=utf-8
endif

function! s:MapMeta() abort
  noremap!        <M-b> <S-Left>
  noremap!        <M-f> <S-Right>
  noremap!        <M-d> <C-O>dw
  cnoremap        <M-d> <S-Right><C-W>
  noremap!        <M-n> <Down>
  noremap!        <M-p> <Up>
  noremap!        <M-BS> <C-W>
  noremap!        <M-C-h> <C-W>
endfunction

if has("gui_running") || has('nvim')
  call s:MapMeta()
else
  silent! exe "set <F29>=\<Esc>b"
  silent! exe "set <F30>=\<Esc>f"
  silent! exe "set <F31>=\<Esc>d"
  silent! exe "set <F32>=\<Esc>n"
  silent! exe "set <F33>=\<Esc>p"
  silent! exe "set <F34>=\<Esc>\<C-?>"
  silent! exe "set <F35>=\<Esc>\<C-H>"
  noremap!        <F29> <S-Left>
  noremap!        <F30> <S-Right>
  noremap!        <F31> <C-O>dw
  cnoremap        <F31> <S-Right><C-W>
  noremap!        <F32> <Down>
  noremap!        <F33> <Up>
  noremap!        <F34> <C-W>
  noremap!        <F35> <C-W>
  if has('terminal')
    tnoremap      <F29> <Esc>b
    tnoremap      <F30> <Esc>f
    tnoremap      <F31> <Esc>d
    tnoremap      <F32> <Esc>n
    tnoremap      <F33> <Esc>p
    tnoremap      <F34> <Esc><C-?>
    tnoremap      <F35> <Esc><C-H>
  endif
  if &encoding ==# 'utf-8' && (has('unix') || has('win32'))
    try
      set encoding=cp949
      call s:MapMeta()
    finally
      set encoding=utf-8
    endtry
  else
    augroup rsi_gui
      autocmd!
      autocmd GUIEnter * call s:MapMeta()
    augroup END
  endif
endif

" vim:set et sw=2:
