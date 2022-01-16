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

    " Assume buffer settings are correct.
    let options .= " --indent-width=".. &shiftwidth
    let options .= " --indent-type="
    if &expandtab
        let options .= "Spaces"
    else
        let options .= "Tabs"
    endif

    let options .= " --line-endings="
    if &ff == "dos"
        let options .= "Windows"
    else
        let options .= "Unix"
    endif

    if &textwidth > 0
        let options .= " --column-width=".. &textwidth
    endif
    
    let l:cmd = printf("%s %s %%t", ale#Escape(l:executable), l:options)
    return {
    \   'command': l:cmd,
    \   'read_temporary_file': 1,
    \ }
endfunction

execute ale#fix#registry#Add('stylua', 'Ale_fixers_stylua_Fix', ['lua'], 'stylua for lua')

