function! s:invader()
  edit `='==SPACE INVADER=='`
  setlocal buftype=nowrite
  setlocal noswapfile
  setlocal bufhidden=wipe
  setlocal buftype=nofile
  setlocal nonumber
  setlocal nolist
  setlocal nowrap
  setlocal nocursorline
  setlocal nocursorcolumn
  let lines = repeat([repeat(' ', &columns)], &lines)
  let lines[16] = repeat(' ', 5).repeat('#', 10).repeat(' ', 10).repeat('#', 10).repeat(' ', 10).repeat('#', 10).repeat(' ', 10).repeat('#', 10).repeat(' ', 5)
  let lines[17] = repeat(' ', 5).repeat('#', 10).repeat(' ', 10).repeat('#', 10).repeat(' ', 10).repeat('#', 10).repeat(' ', 10).repeat('#', 10).repeat(' ', 5)
  let lines[18] = repeat(' ', 5).repeat('#', 10).repeat(' ', 10).repeat('#', 10).repeat(' ', 10).repeat('#', 10).repeat(' ', 10).repeat('#', 10).repeat(' ', 5)
  call setline(1, lines)
  redraw
  let x = 40
  let dx = 0
  let mx = -1
  let my = -1
  syn match InvaderBlock  '#'
  syn match InvaderShip   'A'
  syn match InvaderBeam   '|'
  hi InvaderBlock ctermfg=darkblue ctermbg=darkblue guifg=darkblue guibg=darkblue
  hi InvaderShip  ctermfg=red ctermbg=NONE guifg=red guibg=NONE
  hi InvaderBeam  ctermfg=green ctermbg=NONE guifg=green guibg=NONE
  while 1
    let c = getchar(0)
    if c != 0
      let c = nr2char(c)
      if c == 'q'
        break
      elseif c == 'h'
        let dx = -1
      elseif c == 'l'
        let dx = 1
      elseif c == ' ' && my <= 0
        let mx = x + dx
        let my = 22
      endif
    endif
    let x = x + dx
    if x < 0
      let x = 0
    endif
    if x > &columns-1
      let x = &columns-1
    endif
    if my > 0
      let s = getline(my)
      let s = s[:mx-1].' '.s[mx+1:]
      call setline(my, s)
      if my > 0
        let my -= 1
        let s = getline(my)
        let b = s[mx]
        if b == ' '
          let s = s[:mx-1].'|'.s[mx+1:]
          call setline(my, s)
        else
          let s1 = mx - 1
          let s2 = mx + 1
          if s1 < 0
            let s1 = 0
          endif
          if s1 > len(s)-1
            let s1 = len(s)-1
          endif
          let s = s[:s1-1].'   '.s[s2+1:]
          call setline(my, s)
          let my = -1
        endif
      endif
    endif
    call setline(22, repeat(' ', x).'A'.repeat(' ', &columns-x))
    sleep 30ms
    redraw
  endwhile
  bdelete
endfunction

command! -nargs=* Invader :call s:invader(<f-args>)
