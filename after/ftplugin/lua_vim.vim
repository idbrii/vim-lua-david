" vim plugins written in lua
if expand('%:p') !~# "vim"
    " Not inside a .vim folder, so probably not a vim plugin.
	finish
endif

if has('nvim')
    if david#path#to_unix('%') =~# "/lua/"
        " Lua modules must be cleared from packages to load.
        nnoremap <buffer> <Leader>vso :<C-u>update<CR>:lua require"david.reload".ReloadAll()<CR>
    else
        nnoremap <buffer> <Leader>vso :<C-u>update<CR>:source <C-r>=expand('%:p')<CR><CR>
    endif

	" For nvim, use nicer table output than luaeval.
	"
	" Copy text to @c register and run it through:
	" :lua (run, may include assignments)
	nnoremap <buffer>         <Leader>v; 0"cy$: lua <C-r>c<CR>
	xnoremap <buffer>         <Leader>v; "cy:   lua <C-r>c<CR>
	" :lua= (echo output)
	nnoremap <buffer><silent> <Leader>ve 0"cy$: lua = <C-r>c<CR>
	xnoremap <buffer><silent> <Leader>ve "cy:   lua = <C-r>c<CR>
	" or View (output in buffer).
	nnoremap <buffer>         <Leader>vE 0"cy$:<C-u> call luaeval(printf("View(%s)", @c))<CR>
	xnoremap <buffer>         <Leader>vE "cy:<C-u>   call luaeval(printf("View(%s)", @c))<CR>

else
	nnoremap <buffer>         <Leader>vso :<C-u>update<CR>:luafile <C-r>=expand('%:p')<CR><CR>

	nnoremap <buffer>         <Leader>v; 0"cy$: lua <C-r>c<CR>
	xnoremap <buffer>         <Leader>v; "cy:   lua <C-r>c<CR>
	nnoremap <buffer><silent> <Leader>ve 0"cy$: echo luaeval(@c)<CR>
	xnoremap <buffer><silent> <Leader>ve "cy: echo luaeval(@c)<CR>
endif

" Easy execute line as expression (not statement). Doesn't accept locals or
" assignment.
command! -buffer -bar -range Eval silent <line1>,<line2>yank c | echo luaeval(@c)


