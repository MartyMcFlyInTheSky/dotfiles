" - only alphabetic marks [a-zA-Z] are displayed

" TODO:
" (- multiple marks on one line)
" - optimization: place sign in open but not loaded buffers (e.g. global
"   signs)
" - Visual mode: :marks sets mark at end of line range
" - delete marks
" - ranges in DelMark(a-z)   
" - use complete command modifiers for abbrevs from :h command-modifiers
" - fix: don't display global marks in old files after they have been placed
"   to new file


"==============================================================================
"  Setup signs
"==============================================================================

let g:sign_chars = {}

" Uppercase will replace the uppercase marks
function! s:MapSignChars(foreign_start, uppercase) abort
    let native_start = a:uppercase ? char2nr('A') : char2nr('a')
    let charmap = {}
    let len = a:foreign_start
    for i in range(26)
        let charmap[nr2char(native_start + i)] = nr2char(char2nr(a:foreign_start) + i*3)
    endfor

    " Extend the global map, duplicate entries will be overwritten
    call extend(g:sign_chars, charmap)
endfunc

" Helper: cross-compatible sign define
function! s:DefineSign(name, text, hl) abort
  " Neovim provides sign_define() as a function wrapper
  if exists('*sign_define')
    call sign_define(a:name, {'text': a:text, 'texthl': a:hl})
  else
     Vim: use the Ex command
    execute printf('sign define %s text=%s texthl=%s', a:name, a:text, a:hl)
  endif
endfunction

call s:MapSignChars('󰯭', v:false)
call s:MapSignChars('󰯫', v:true)

function! s:SetupSigns() abort
    " For each entry in the sign chars list create a sign 
    for [key, val] in items(g:sign_chars)
        " Use the same highlight group as marks.nvim just so we don't have to
        " redefine it in colorscheme
        call s:DefineSign('vm' . key, val, 'MarkSignHL')
    endfor
endfunc

" Check if plugin is loaded
if exists('g:loaded_vm_signs')
"  finish
else
endif
let g:loaded_vm_signs = 1

call s:SetupSigns()

let g:marks_sign_id_range_start = 9000
let g:mark_group = "marksigns"


"==============================================================================
"  Global Accessors
"==============================================================================

function! s:Mark(letter) abort
    " Remove potential old signs before replacing
    if a:letter =~# "^[A-Z]$"
        let mark = "'".a:letter            " e.g. 'A -> "'A"
        let bufnr = bufnr('%')
        let marks = getmarklist()
        " getmarklist returns {mark, pos: [bufnr, lnum, col, off], file}
        " TODO: Investigate if it's really necessary to check for lnum > 0?
        let i = indexof(marks, {_,m ->
                    \ get(m,'mark','') ==# mark
                    \ && get(m,'pos',[0,0])[0] == bufnr
                    \ && get(m,'pos',[0,0])[1] > 0 })

        if i >= 0
            " Remove sign
            let sign_id = char2nr(a:letter)
            call sign_unplace(g:mark_group, {'buffer': bufnr, 'id': sign_id})
        endif

    elseif a:letter =~# "^[a-z]$"
        let mark = "'".a:letter
        let bufnr = bufnr('%')
        let marks = getmarklist(bufnr)

        let i = indexof(marks, {_,m ->
                    \ get(m,'mark','') ==# mark
                    \ && get(m,'pos',[0,0])[1] > 0 })
        if i >= 0
            " Remove sign
            let sign_id = char2nr(a:letter)
            call sign_unplace(g:mark_group, {'buffer': bufnr, 'id': sign_id})
        endif
    " else
        " Not important since we only display alphabetic marks so we don't
        " care
    endif

    " TODO: Investigate if possible to place signs for unloaded files (as
    " chatgpt indicates)
    
    " Place new sign
    " Mark
    " TODO: When setting an uppercase mark "bufnum" is
    "       used for the mark position.
    let sign_name = 'vm'.a:letter
    let sign_id = char2nr(a:letter)
    call sign_place(sign_id, g:mark_group, sign_name, bufnr('%'), { 'lnum': line('.')})
    call setpos("'".a:letter, [bufnr('%'), line('.'), col('.') ])
endfunction

function! s:DelMark(letter) abort
    " TODO: Support ranges here
    " Retrieve sign
    let sign_name = 'vm'.a:letter
    let sign_id = char2nr(a:letter)

    " Unplace sign
    call sign_unplace(g:mark_group, {'buffer': bufnr('%'), 'id': sign_id})

   " From help: Use a zero "lnum" to delete a mark 
    call setpos("'".a:letter, [bufnr('%'), 0, 0, 0])
endfunction


"==============================================================================
" Auto BufMark setup  
"==============================================================================

function! s:SetupBufMarks(bufnr)
    " 1: We need to build the dict on VimEnter, and on BufEnter we need to
    " place the signs
    " The dict being constructed on VimEnter happens automatically when we
    " load the plugin
    "
    
     " Local marks
     let marks = filter(getmarklist(a:bufnr),
      \ {_, m -> m.mark =~ "^'[a-z]$"})

     " returns {mark, pos: [bufnr, lnum, col, off], file}
 
     " Filter out all special marks and place the sign
     for m in marks
         let letter = m.mark[1:] 
         " Place sign
         let sign_id = char2nr(letter)
         let sign_name = 'vm'.letter
         let linenr = m.pos[1]
         call sign_place(sign_id, g:mark_group, sign_name, a:bufnr, { 'lnum': linenr })
     endfor

     " Global marks pointing to this buffer
     " TODO: Investigate if possible to place signs for unloaded files (as
     " chatgpt indicates)
     let gmarks = filter(getmarklist(),
      \ {_, m -> m.mark =~ "^'[A-Z]$"
      \          && m.pos[1] > 0
      \          && m.pos[0] == a:bufnr })

     for m in gmarks
         let letter = m.mark[1:] 
         " Place sign
         let sign_id = char2nr(letter)
         let sign_name = 'vm'.letter
         let linenr = m.pos[1]
         call sign_place(sign_id, g:mark_group, sign_name, a:bufnr, { 'lnum': linenr })
     endfor
    
endfunc


augroup MyBufEnter!
    autocmd!
    autocmd BufEnter * call s:SetupBufMarks(str2nr(expand('<abuf>')))
augroup END



"==============================================================================
"  Keymappings
"==============================================================================

function! s:SetupMappings() abort
    " The reason to setup mappings like this and not e.g. with a dispatch
    " function that waits for the next letter after typing 'm' is to avoid
    " the intermittent switching of the cursor to the commandline
    for [key, val] in items(g:sign_chars)
        exec printf("nnoremap m%s <Cmd>call <SID>Mark('%s')<CR>", key, key)
    endfor
endfunc

call s:SetupMappings()


"==============================================================================
"  Commands
"==============================================================================

" Mark {letter}  — allow !, forbid ranges, forward to one function
" <bang>0 becomes either 0 or !0 -> 1 (true)
command! -nargs=1 Mark
      \ call <SID>Mark(<f-args>)

" DelMarks [args...] — allow !, forbid ranges, forward to one function
command! -nargs=* -bang DelMarks
      \ call <SID>DelMarks(<q-args>, <bang>0)


"==============================================================================
"  Abbreviations
"==============================================================================

" Not a perfect solution but good enough. The idea can be extended.
function! s:IsCmdPosition(lhs) abort
  if getcmdtype() !=# ':' | return 0 | endif

  let line = getcmdline()
  let pos  = getcmdpos() - 1                    " cursor is *after* last typed char and 1-based
  let start = pos - strlen(a:lhs)               " where the LHS would begin

  " text before the candidate token
  let head = strpart(line, 0, start)
  let head = substitute(head, '^\s*', '', '')

  " strip known command modifiers repeatedly
  let pat_mod = '\%(\%(sil\%[ent]!\?'
        \ . '\|verb\%[ose]\d*'
        \ . '\)\s\+\)'
  while head =~? pat_mod
    let head = substitute(head, pat_mod, '', '')
  endwhile

  " strip an initial [range] if present (%, ., $, 'x, numbers, /pat/, ?pat?, with , or ; chains and offsets)
  let pat_addr = '\%(%\|[.$]\|''[<>]\|''\k\|\%([/?].\{-}[/?]\)\|\d\+\)'
  let pat_range = '^\s*' . pat_addr . '\%(\s*[,;]\s*' . pat_addr . '\)*\%(\s*[+-]\d\+\)\=\s*'
  let head2 = substitute(head, pat_range, '', '')

  " if nothing remains, the next token is the command word
  return head2 ==# ''
endfunction


" SetupAbbrev({spec}, {target}, [{buffer}])
"   {spec}   : help-style command spec, e.g. "[range]delm[arks]!" or "[range]ma[rk]"
"   {target} : the command name to expand to, e.g. "DelMarks" or "Mark"
"   {buffer} : optional bool; when v:true, create buffer-local abbreviations
"
" Examples:
"   call SetupAbbrev('delm[arks]!', 'DelMarks')
"   call SetupAbbrev('ma[rk]',      'Mark')
function! s:SetupAbbrev(spec, target) abort
    " Get first optional argument (buflocal: bool)
    let buflocal = get(a:, 1, v:false)

    " 1) Detect if command accepts a bang at the end
    " Case sensitive
    let has_bang = a:spec =~# '!\s*$'
    let s = substitute(a:spec, '!\s*$', '', '')

    " 2) Extract the command token (up to whitespace / arg spec)
    "    Expect forms like "delm[arks]" or "ma[rk]" or just "write"
    let m = matchlist(s, '^\(\a\+\)\(\[\a\+\]\)\?')
    if empty(m)
        echoerr 'SetupAbbrev(): cannot parse command in spec: ' . string(a:spec)
        return
    endif
    let min   = m[1]                    " minimal abbreviation (e.g. 'delm', 'ma')
    let rest  = m[2] ==# '' ? '' : m[2][1:-2]  " strip the [ ... ] to get 'arks' or 'rk'

    " 3) Build all valid abbreviations of the command name
    let abbrs = []
    call add(abbrs, min)                " minimal
    for i in range(1, strlen(rest))
        call add(abbrs, min . strpart(rest, 0, i))
    endfor

    " 4) Define the abbreviations (plain and with bang if supported)
    "    Using cnoreabbrev (not <expr>) lets Vim handle ranges naturally.
    let scope = buflocal ? '<buffer> ' : ''
    for lhs in abbrs
        if !has_bang
            " plain
            execute printf(
                        \ 'cnoreabbrev %s<expr> %s! <SID>IsCmdPosition(%s) ? %s! : %s!',
                        \ scope,
                        \ lhs,
                        \ string(lhs),
                        \ string(a:target),
                        \ string(lhs))
        else 
            " bang variant (e.g., "delm!" → "DelMarks!")
            execute printf(
                        \ 'cnoreabbrev %s<expr> %s <SID>IsCmdPosition(%s) ? %s : %s',
                        \ scope,
                        \ lhs,
                        \ string(lhs),
                        \ string(a:target),
                        \ string(lhs))
        endif
    endfor
endfunction

call s:SetupAbbrev("delm[arks]", "DelMarks")
call s:SetupAbbrev("delm[arks]!", "DelMarks!")
call s:SetupAbbrev("ma[rk]!", "Mark")

