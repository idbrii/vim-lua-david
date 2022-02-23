" vim plugins written in lua
if expand('%:p') !~# "vim"
    " Not inside a .vim folder, so probably not a vim plugin.
	finish
endif

nnoremap <buffer> <Leader>vso :<C-u>update<CR>:luafile <C-r>=expand('%:p')<CR><CR>
