" Ale setup for stylua

" https://github.com/JohnnyMorganz/StyLua
let g:ale_lua_stylua_executable = expand('~/.vim-cache/bin/stylua')
let g:ale_lua_stylua_options = '--search-parent-directories'

" Config is local-only for now. Should be ale#fixers#stylua#Fix and need to
" register in autoload/ale/fix/registry.vim
" call ale#Set('lua_stylua_executable', 'stylua')
" call ale#Set('lua_stylua_options', '')
function! Ale_fixers_stylua_Fix(buffer) abort
    let l:executable = ale#Var(a:buffer, 'lua_stylua_executable')
    let l:options = ale#Var(a:buffer, 'lua_stylua_options')

    let l:cmd = printf("%s %s %%t", ale#Escape(l:executable), l:options)
    return {
    \   'command': l:cmd,
    \   'read_temporary_file': 1,
    \ }
endfunction

execute ale#fix#registry#Add('stylua', 'Ale_fixers_stylua_Fix', ['lua'], 'stylua for lua')

