" Member function calls require a :
" This should show as an error: self.IsInCommentOrString()
" Hack around polyglot's lua syntax (which makes self a builtin and I don't
" know how to handle that in vim syntax).
syn clear luaBuiltIn
syn keyword luaBuiltIn _ENV
syn match luaError "self\(\.\l\+\)*\.\u\w\+(" display

" Our class system uses _base as the parent class. We want the instance passed
" as self and not the class.
syn match luaError "\<_base:" display
" Lua uses ~= for not equal.
syn match luaError "!=" display

" TODO: these two don't work anymore
" Lua does not support assignment-equals
syn match luaError "[+-]=" display
" Lua uses 1-indexed arrays
" TODO: this isn't necessarily wrong. warning would be nice.
syn match luaError contains=@luaBase,luaNoise "\[0]" display
" Lua uses % to escape atoms (vim \w is %w)
syn match luaError "\v<(find|g?match|gsub)>.*\\[wad]" display


" Constants are all caps with underscores. Minimum 4 characters.
" Source: http://stackoverflow.com/questions/1512602/highlighting-defined-value-in-vim/1515550#1515550
syn match luaPseudoConstant "\<[A-Z][A-Z0-9_]\{3,\}\>"
hi def link luaPseudoConstant Define

" Make functions look like functions (vim-lua#19)
hi def link luaFuncCall Function
hi link luaFuncName Function
" Ensure function keywords never look like function names.
hi link luaFuncKeyword Type
" Make local a keyword like return
hi! def link luaLocal Statement
