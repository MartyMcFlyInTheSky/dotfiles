
let s:wezterm_cli_path = "$HOME/.local/bin/wetzerm"

let g:prev_win = v:null

let s:b64_table = [
  \ 'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P',
  \ 'Q','R','S','T','U','V','W','X','Y','Z','a','b','c','d','e','f',
  \ 'g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v',
  \ 'w','x','y','z','0','1','2','3','4','5','6','7','8','9','+','/']

function! s:encode_b64(str, size)
  let bytes = map(range(len(a:str)), 'char2nr(a:str[v:val])')
  let b64 = []

  for i in range(0, len(bytes) - 1, 3)
    let n = bytes[i] * 0x10000
          \ + get(bytes, i + 1, 0) * 0x100
          \ + get(bytes, i + 2, 0)
    call add(b64, s:b64_table[n / 0x40000])
    call add(b64, s:b64_table[n / 0x1000 % 0x40])
    call add(b64, s:b64_table[n / 0x40 % 0x40])
    call add(b64, s:b64_table[n % 0x40])
  endfor

  if len(bytes) % 3 == 1
    let b64[-1] = '='
    let b64[-2] = '='
  endif

  if len(bytes) % 3 == 2
    let b64[-1] = '='
      endif

      let b64 = join(b64, '')
      if a:size <= 0
        return b64
      endif

      let chunked = ''
      while strlen(b64) > 0
        let chunked .= strpart(b64, 0, a:size) . "\n"
        let b64 = strpart(b64, a:size)
      endwhile

      return chunked
    endfunction


    function! s:on_exit()
        let l:format_var = s:format_wezterm_var('false')
        call s:write_wezterm_var(l:format_var)
    endfun


    function! s:on_init()
        let l:format_var = s:format_wezterm_var('true')
        call s:write_wezterm_var(l:format_var)
    endfun


    function! s:write_wezterm_var(var)
      if filewritable('/dev/fd/2') == 1
        let l:success = writefile([a:var], '/dev/fd/2', 'b') == 0
      else
        let l:success = chansend(v:stderr, a:var) > 0
      endif
      return l:success
endfunction


function! s:format_wezterm_var(val)
  return printf("\033]1337;SetUserVar=IS_NVIM=%s\007", s:encode_b64(a:val, 0))
endfunction


function! s:startup() abort
    " buffer tracking for 'previous buffer'
    augroup SmartSplitsPrevWin
        autocmd!
        autocmd WinLeave * let g:prev_win = win_getid()
    augroup END

    " Assume multiplexer is always wezterm in our case

    " on_init
    call s:on_init()
    augroup SmartSplitsOnInit
        autocmd!
        autocmd VimResume * call <SID>on_init()
    augroup END

    " on_exit
    augroup SmartSplitsOnExit
        autocmd!
        autocmd VimSuspend,VimLeavePre * call <SID>on_exit()
    augroup END
endfunction

function! MergeOrSplitRight() abort
    if winnr() == winnr('l')
        belowright vsp 
    else
        wincmd l
        close
        wincmd p
    endif
endfunc

function! MergeOrSplitLeft() abort
    if winnr() == winnr('h')
        leftabove vsp
    else
        wincmd h
        close
        wincmd p
    endif
endfunc

call s:startup()

