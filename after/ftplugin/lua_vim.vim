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
else
	nnoremap <buffer> <Leader>vso :<C-u>update<CR>:luafile <C-r>=expand('%:p')<CR><CR>
endif

