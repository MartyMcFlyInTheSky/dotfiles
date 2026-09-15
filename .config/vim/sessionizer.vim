
function! s:SaveSessionAndQuit()
    " NOTE: Use PWD instead of vim's getcwd() since it doesn't resolve symlinks.
    " If we reset cwd from inside vim this will not adapt though, but it's safer this way.
    if empty($PWD)
        echohl ErrorMsg | echo "PWD is not set" | echohl None
        return
    endif

    let cwd = expand('$PWD')
    let sdir = cwd . '/.nvim'
    if !isdirectory(sdir)
        echohl WarningMsg | echom "No .nvim directory, skipping session." | echohl None
        silent! wqall
        return
    endif

    " 1) (Optional) If we whave unsaved changes to any buffers prompt user to
    " save or abort
    let modbufs = getbufinfo({'bufmodified': 1})
    let saveable_modbufs = []
    for buf in modbufs
        if getbufvar(buf.bufnr, '&buftype') ==# '' && getbufvar(buf.bufnr, '&buflisted') == 1
            call add(saveable_modbufs, buf)
        endif
    endfor

    if !empty(saveable_modbufs)
        let entries = []
        for buf in saveable_modbufs
            let bnr = buf.bufnr
            let label = (bnr == bufnr('%')) ? ('current(' . bnr . ')') : string(bnr)

            let name = bufname(bnr)
            let full = empty(name) ? '' : fnamemodify(name, ':p')
            let outside = (!empty(full) && full !~# '^' . escape(cwd, '\') . '/')

            call add(entries, {'text': label, 'outside': outside})
        endfor

        echohl WarningMsg
        echon 'Modified buffers: '
        for i in range(0, len(entries) - 1)
            if entries[i].outside
                echohl ErrorMsg
            else
                echohl WarningMsg
            endif
            echon entries[i].text
            if i < len(entries) - 1
                echohl WarningMsg
                echon ', '
            endif
        endfor
        echohl WarningMsg
        echon '. Confirm save all with <C-s> or abort with <Esc>'
        echohl None

        let ch = getcharstr()
        if ch !=# "\<C-s>"
            echohl WarningMsg | echom 'Buffer save canceled.' | echohl None
            return
        endif
    endif

    " 2) Declare new session if not already declared
    let sessionfile = v:this_session
    if empty(sessionfile)
        let sessionfile = sdir . '/session.vim'
    endif

    " Drop non-saveable buffers before writing the session
    for buf in getbufinfo()
        if getbufvar(buf.bufnr, '&buftype') !=# '' || getbufvar(buf.bufnr, '&buflisted') == 0
            execute 'bwipeout' buf.bufnr
        endif
    endfor

    " 3) Write sessionfile
    exec printf("mksession! %s", fnameescape(sessionfile))

    " 4) Exit (now everything should be saved)
     silent! wqall
endfunc


command! -nargs=0 SaveSessionAndQuit
      \ call <SID>SaveSessionAndQuit()
