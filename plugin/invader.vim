let s:loop = 1
let s:ship = { "x": 40, "dx": -1, "missile": { "x": -1, "y": -1 } }
let s:enemies = { "dx": -1, "e":[], "st": 10, "missile": { "x": -1, "y": -1 } }

let s:cursor = ''

let s:rand_num = 1
function! s:rand()
  if has('reltime')
    let match_end = matchend(reltimestr(reltime()), '\d\+\.') + 1
    return reltimestr(reltime())[l:match_end : ]
  else
    let s:rand_num += 1
    return s:rand_num
  endif
endfunction

function! s:update(x, y, c)
  let s = getline(a:y)
  let o = ''
  if a:x > 0
    let o .= s[:a:x-1]
  elseif a:x < 0
    let o .= a:c[-a:x :]
  endif
  let o .= a:c
  let o .= s[a:x+(len(a:c)+1)-1:]
  call setline(a:y, o)
endfunction

function! s:cursor_on(f)
  if s:cursor == ''
    redir => s:cursor
    silent! hi Cursor
    redir END
    let s:cursor = substitute(matchstr(s:cursor, 'xxx\zs.*'), "\n", ' ', 'g')
  endif
  if a:f
    exe "hi Cursor ".s:cursor
  else
    hi Cursor ctermfg=NONE ctermbg=NONE guifg=NONE guibg=NONE
  endif
endfunction

function! s:ship.work() dict
  let c = nr2char(getchar(0))
  if c == 'q'
    let s:loop = -1
  elseif c == 'h'
    let self.dx = -1
  elseif c == 'l'
    let self.dx = 1
  elseif c == ' ' && self.missile.y <= 0
    let self.missile.x = self.x + self.dx
    let self.missile.y = 22
    if self.missile.x < 0
      let self.missile.x = 0
    endif
    if self.missile.x > 80-1
      let self.missile.x = 80-1
    endif
  endif
  call self.missile.work()

  call s:update(self.x, 22, ' ')
  let self.x = self.x + self.dx
  if self.x < 0
    let self.x = 0
  endif
  if self.x > 80-1
    let self.x = 80-1
  endif
  call s:update(self.x, 22, 'A')
endfunction

function! s:ship.missile.work() dict
  if self.y > 0
    call s:update(self.x, self.y, ' ')
    let self.y -= 1
    let s = getline(self.y)
    let b = s[self.x]
    if b =~ '[vV]'
      let et = []
      for e in s:enemies.e
        if (e[0] == self.x || e[0]+1 == self.x) && e[1] == self.y
          let self.y = -1
          call s:update(e[0], e[1], '  ')
        else
          call add(et, e)
        endif
      endfor
      let s:enemies.e = et
      if len(s:enemies.e) == 0
        let s:loop = 0
        return
      endif
    elseif b == '#'
      call s:update(self.x-1, self.y, '   ')
      let self.y = -1
    else
      call s:update(self.x, self.y, '|')
    endif
  endif
endfunction

function! s:enemies.work() dict
  let self.st -= 1
  if self.st == 0
    let self.st = 10
    for e in self.e
      call s:update(e[0], e[1], '  ')
    endfor
    let dx = self.dx
    let dxt = dx
    for e in self.e
      let e[0] += dx
      if e[0] < 1 || e[0] > s:w-2
        let dxt = -dx
      endif
    endfor
    if dx != dxt
      for e in self.e
        let e[1] += 1
        if e[1] > 16
          let s:loop = -3
          return
        endif
      endfor
    endif
    let self.dx = dxt
  endif
  if self.st < 5
    for e in self.e
      call s:update(e[0], e[1], 'vv')
    endfor
  else
    for e in self.e
      call s:update(e[0], e[1], 'VV')
    endfor
  endif

  if self.missile.y == -1
    if s:rand() < 5000
      let e = self.e[s:rand() % len(self.e)]
      let self.missile.x = e[0]
      let self.missile.y = e[1]
    endif
  else
    call self.missile.work()
  endif
endfunction

function! s:enemies.missile.work() dict
  if self.y > 0
    call s:update(self.x, self.y, ' ')
    let self.y += 1
    if self.y > s:h
      let self.y = -1
      return
    endif
    let s = getline(self.y)
    let b = s[self.x]
    if b == 'A'
      let s:loop = -2
      return
    elseif b == '#'
      call s:update(self.x-1, self.y, '   ')
      let self.y = -1
    else
      call s:update(self.x, self.y, '$')
    endif
  endif
endfunction

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
  let s:w = 80
  let s:h = 25
  let lines = repeat([repeat(' ', s:w)], s:h)
  for l in [16,17,18]
    let lines[l] = repeat(' ', 5).repeat('#', 10).repeat(' ', 10).repeat('#', 10).repeat(' ', 10).repeat('#', 10).repeat(' ', 10).repeat('#', 10).repeat(' ', 5)
  endfor
  call setline(1, lines)
  redraw
  syn match InvaderBlock  '#'
  syn match InvaderShip   'A'
  syn match InvaderBeam   /[|\$]/
  syn match InvaderEnemy  /[vV]/
  hi InvaderBlock ctermfg=darkblue ctermbg=darkblue guifg=darkblue guibg=darkblue
  hi InvaderShip  ctermfg=red ctermbg=NONE guifg=red guibg=NONE
  hi InvaderBeam  ctermfg=green ctermbg=NONE guifg=green guibg=NONE
  hi InvaderEnemy ctermfg=yellow ctermbg=NONE guifg=yellow guibg=NONE

  let s:enemies.e = [
  \ [5, 1], [8, 1], [11, 1], [14, 1],
  \ [5, 3], [8, 3], [11, 3], [14, 3]
  \]

  let s:loop = 1
  call s:cursor_on(0)
  while s:loop == 1
    call s:enemies.work()
    call s:ship.work()
    sleep 50ms
    redraw
  endwhile
  if s:loop == -1
    echohl WarningMsg | echomsg "Game Canceled" | echohl NONE
  elseif s:loop == 0
    echohl WarningMsg | echomsg "Game Clear" | echohl NONE
  else
    echohl WarningMsg | echomsg "Game Over" | echohl NONE
  endif
  call s:cursor_on(1)
  bdelete
endfunction

command! Invader :call s:invader()

