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
  for l in [16,17,18]
    let lines[l] = repeat(' ', 5).repeat('#', 10).repeat(' ', 10).repeat('#', 10).repeat(' ', 10).repeat('#', 10).repeat(' ', 10).repeat('#', 10).repeat(' ', 5)
  endfor
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

  let es = [[5, 1], [10, 1]]
  let [emin, emax] = [&columns, -1]
  for e in es
    if e[0] < emin
      let emin = e[0]
    endif
    if e[0] > emax
      let emax = e[0]
    endif
  endfor
  let edx = -1
  let est = 10

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
    let est -= 1
    if est == 0
      let est = 10
      for e in es
        let s = getline(e[1])
        let s = s[:e[0]-1].' '.s[e[0]+1:]
        call setline(e[1], s)
      endfor
      for e in es
        let e[0] += edx
        if e[0] < 1
          let edx = 1
          for ee in es
            let ee[1] += 1
          endfor
        endif
        if e[0] > &columns-2
          let edx = -1
          for ee in es
            let ee[1] += 1
          endfor
        endif
      endfor
      for e in es
        let s = getline(e[1])
        let s = s[:e[0]-1].'v'.s[e[0]+1:]
        call setline(e[1], s)
      endfor
    elseif est < 5
      for e in es
        let s = getline(e[1])
        let s = s[:e[0]-1].'v'.s[e[0]+1:]
        call setline(e[1], s)
      endfor
    else
      for e in es
        let s = getline(e[1])
        let s = s[:e[0]-1].'V'.s[e[0]+1:]
        call setline(e[1], s)
      endfor
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
          if s1 < 1
            let s1 = 1
          endif
          if s1 > len(s)-2
            let s1 = len(s)-2
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
