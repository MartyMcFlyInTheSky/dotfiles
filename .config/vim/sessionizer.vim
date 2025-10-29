" TODO:
" - display "current" if the buffer save would only affect the current buffer
" - fix: display "not a dev repo" before prompting to save
" - display a text in console when current dir is not a dev dir instead of
"   silently neglecting the command
" - fix temporary file remaining an arg

function! s:SaveSessionAndQuit()

    " 1) (Optional) If we whave unsaved changes to any buffers prompt user to
    " save or abort
    let modbufs = getbufinfo({'bufmodified': 1})
    if !empty(modbufs)
        " Convert each item in modbufs into its buffer number
        let bufnums = map(modbufs, 'v:val.bufnr')
        let buflist = join(bufnums, ', ')

        " Highlighted warning with the buffer list included
        echohl WarningMsg
        echom "Modified buffers: " . buflist . ". Confirm save all with <C-s> or abort with <Esc>"
        echohl None

        let ch = getchar()
        " TODO
        if type(ch) == type(0)
            if ch == 19
                " <C-s>
                " Saving everything is ok!
            else
                " if ch == 27
                " <ESC>
                echohl WarningMsg | echom "Buffer save canceled." | echohl None
                return
            endif
        else
            echohl WarningMsg | echom "Buffer save canceled." | echohl None
            return
        endif
    endif

    " 2) Declare new session if not already declared
    let sessionfile = v:this_session
    if empty(sessionfile)
        " Check if we're in a dev repo, otherwise abort

        " NOTE: Use PWD instead of vim's getcwd() since it doesn't resolve symlinks.
        " If we reset cwd from inside vim this will not adapt though, but it's safer this way.
        if empty($PWD)
            echohl ErrorMsg | echo "PWD is not set" | echohl None
            return
        endif

        let cwd = expand('$PWD')
        if fnamemodify(cwd, ':h') != expand('~/dev') && fnamemodify(cwd, ':h') != expand('~/dev2')
            echohl InfoMsg | echom "Not a dev repo, do nothing." | echohl None
            return
        endif
        
        " Project specific directory. Use '.vscode' - directory within the project
        if has('nvim')
            let sdir = cwd . '/.vscode/nvim'
        else
            let sdir = cwd . '/.vscode/vim'
        endif
        call mkdir(sdir, 'p')

        " NOTE: vim and nvim sessionfiles have drifted apart, so we need to
        " differentiate even here
        let sessionfile = sdir . '/session.vim'

        " Setup persistent undo (written on buffer save)
        if has('persistent_undo')
            let &undodir = sdir . "/undodir/"
            set undofile
        endif

        " Setup viminfo / shadafile (written on vim quit)
        let &viminfofile = sdir . '/session.data'
    endif
    
    " 3) Write sessionfile
    exec printf("mksession! %s", fnameescape(sessionfile))

    " 4) Exit (now everything should be saved)
     silent! wqall
endfunc


" returns 1 if str matches ANY pattern in pats
function! s:MatchesAny(str, pats) abort
  for p in a:pats
    if a:str =~# p
      return 1
    endif
  endfor
  return 0
endfunc

function! s:PatchSession() abort
    " 1) Read sessionfile

    let sessionfile = v:this_session
    if !filereadable(sessionfile)
        echoerr "Sessionfile doesn't exist or is not readable, aborting"
        return
    endif
    let lines = readfile(sessionfile)

    "2) Patch session to make args passed to nvim -S <session> propagate
    " with priority over the args setup by the session
    let idx1 = -1
    for i in range(0, len(lines) - 1)
        if lines[i] =~# '^argglobal'
            let idx1 = i
            break
        endif
    endfor
   
    let idx2 = -1 
    let pats = ['\v\%argdel', '\v^\$argadd\s(.*)$', '\v^\d+argu', '^argglobal', '\v^edit\s(.*)$'] 
    for i in range(idx1+1, len(lines) -1)
        if !s:MatchesAny(lines[i], pats)
            let idx2 = i "sentinel not included in deleted lines
            break
        endif
    endfor
    " If no second marker, take end of file
    if idx2 < 0
        let idx2 = len(lines)
    endif

    " Start with the global arglist
    let files = argv(-1)

    " Absolute path of current buffer (empty if unnamed)
    let cur = expand('%:p')

    " Add it if it’s a real file and not already in the list
    if !empty(cur)
        " compare as absolute paths to avoid dupes with relative entries
        let abs_files = map(copy(files), {_, v -> fnamemodify(v, ':p')})
        if index(abs_files, cur) < 0
            call add(files, cur)
        endif
    endif

    " Now build the commands (reverse because we use 0argadd)
    let argcmds = map(reverse(copy(files)),
                \ {_, f -> printf('0argadd %s', fnameescape(f))})

    " Remove the block [idx1, idx2]
    call remove(lines, idx1, idx2-1)

    " Assemble new block
    let block = [
                \ '" --- custom argglobal begin ---',
                \ 'argglobal',
                \ ]
    call extend(block, argcmds) 
    call add(block, 'silent! last')
    call add(block, '" --- custom argglobal end ---')

    " Insert to main block
    call extend(lines, block, idx1)

    " 3) Patch add undofile

    " Find the first line that defines s:so_save (typical in mksession output)
    let idx = -1
    for i in range(len(lines))
        if lines[i] =~# '^let s:so_save = '
            let idx = i
            break
        endif
    endfor
    if idx < 0
        echoerr 'Could not locate "s:so_save" in: ' . sessionfile
        return
    endif

    " Patch in loading of the right shadafile
    " Post-write patching of the sessionscript is necessary because undodir is
    " not preserved across sessions
    let block = [
                \ '" --- custom session options begin ---',
                \ 'let s:sdir = expand(''<sfile>:p:h'')',
                \ 'if has(''persistent_undo'')',
                \ '  set undofile',
                \ '  call mkdir(s:sdir . ''/undodir'', ''p'')',
                \ '  let &undodir = s:sdir . ''/undodir/''',
                \ 'endif',
                \ '" --- custom session options end ---',
                \ ]

    " Insert just before the s:so_save line
    call extend(lines, block, idx)

    call writefile(lines, sessionfile)
    echom 'Patched: ' . sessionfile
endfunc


command! -nargs=0 SaveSessionAndQuit
      \ call <SID>SaveSessionAndQuit()

command! -nargs=0 PatchSession
      \ call <SID>PatchSession()


augroup SessionScopeState!
    autocmd!
    autocmd SessionWritePost * call s:PatchSession()
augroup END

