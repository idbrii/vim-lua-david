" Intended to run on top of vim-lua's indent.
" Fixes anon funcs in chained function calls:
"  if true then
"      local data = self.kitchen
"              :getContents()
"              :getCheese()
"              :enjoyCheese(self
"                  :mouth()
"                  :open()
"                  :extendTongue())
"              :eatCheese({fn = function()
"              return 10
"          end})
"      self:Func()
"  end
" https://github.com/tbastos/vim-lua
" TODO: I've submitted this as a PR at tbastos/vim-lua, so remove this file
" when that is merged and appears in polyglot.
setlocal indentexpr=DavidGetLuaIndent(v:lnum)

" Only define the function once.
if exists("*DavidGetLuaIndent")
  finish
endif

" Variables -----------------------------------------------{{{1

let s:open_patt = '\C\%(\<\%(function\|if\|repeat\|do\)\>\|(\|{\)'
let s:middle_patt = '\C\<\%(else\|elseif\)\>'
let s:close_patt = '\C\%(\<\%(end\|until\)\>\|)\|}\)'

let s:anon_func_start = '\S\+\s*[({].*\<function\s*(.*)\s*$'
let s:anon_func_end = '\<end\%(\s*[)}]\)\+'

let s:chained_func_call = "^\\v\\s*[:.]\\w+[({\"']"

" Expression used to check whether we should skip a match with searchpair().
let s:skip_expr = "synIDattr(synID(line('.'),col('.'),1),'name') =~# 'luaComment\\|luaString'"

" Auxiliary Functions -------------------------------------{{{1

function s:IsInCommentOrString(lnum, col)
  return synIDattr(synID(a:lnum, a:col, 1), 'name') =~# 'luaCommentLong\|luaStringLong'
        \ && !(getline(a:lnum) =~# '^\s*\%(--\)\?\[=*\[') " opening tag is not considered 'in'
endfunction

" Find line above 'lnum' that isn't blank, in a comment or string.
function s:PrevLineOfCode(lnum)
  let lnum = prevnonblank(a:lnum)
  while s:IsInCommentOrString(lnum, 1)
    let lnum = prevnonblank(lnum - 1)
  endwhile
  return lnum
endfunction

" Gets line contents, excluding trailing comments.
function s:GetContents(lnum)
  return substitute(getline(a:lnum), '\v--.*$', '', '')
endfunction

" GetLuaIndent Function -----------------------------------{{{1

function! DavidGetLuaIndent(lnum)
  " if the line is in a long comment or string, don't change the indent
  if s:IsInCommentOrString(a:lnum, 1)
    return -1
  endif

  let prev_line = s:PrevLineOfCode(a:lnum - 1)
  if prev_line == 0
    " this is the first non-empty line
    return 0
  endif

  let contents_cur = s:GetContents(a:lnum)
  let contents_prev = s:GetContents(prev_line)

  let original_cursor_pos = getpos(".")

  " count how many blocks the previous line opens
  call cursor(a:lnum, 1)
  let num_prev_opens = searchpair(s:open_patt, s:middle_patt, s:close_patt,
        \ 'mrb', s:skip_expr, prev_line)

  " count how many blocks the current line closes
  call cursor(prev_line, col([prev_line,'$']))
  let num_cur_closes = searchpair(s:open_patt, s:middle_patt, s:close_patt,
        \ 'mr', s:skip_expr, a:lnum)

  let i = num_prev_opens - num_cur_closes

  " if the previous line closed a paren, outdent (except with anon funcs)
  call cursor(prev_line - 1, col([prev_line - 1, '$']))
  let num_prev_closed_parens = searchpair('(', '', ')', 'mr', s:skip_expr, prev_line)
  if num_prev_closed_parens > 0 && contents_prev !~# s:anon_func_end
    let i -= 1
  endif

  " if this line closed a paren, indent (except with anon funcs)
  call cursor(prev_line, col([prev_line, '$']))
  let num_cur_closed_parens = searchpair('(', '', ')', 'mr', s:skip_expr, a:lnum)
  if num_cur_closed_parens > 0 && contents_cur !~# s:anon_func_end
    let i += 1
  endif

  " if the current line chains a function call to previous unchained line
  if contents_prev !~# s:chained_func_call && contents_cur =~# s:chained_func_call
    let i += 1
  endif

  " if the current line chains a function call to previous unchained line
  if contents_prev =~# s:chained_func_call && contents_cur !~# s:chained_func_call
    let i -= 1
  endif

  " special case: call(with, {anon = function() -- should indent only once
  if i > 1 && contents_prev =~# s:anon_func_start
    let i = 1
  endif

  " special case: end}) -- end of call w/ anon func should outdent only once
  if i < -1 && contents_cur =~# s:anon_func_end
    let i = -1
  endif

  " special case: end}) -- line after end of call w/ anon func should outdent again
  if i >= 0 && contents_prev =~# s:anon_func_end
    let i -= 1
  endif

  " restore cursor
  call setpos(".", original_cursor_pos)

  return indent(prev_line) + (shiftwidth() * i)

endfunction
