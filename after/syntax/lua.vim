" Member function calls require a :
" This should show as an error: self.IsInCommentOrString()
" Hack around polyglot's lua syntax (which makes self a builtin and I don't
" know how to handle that in vim syntax).
syn clear luaBuiltIn
syn keyword luaBuiltIn _ENV
syn match luaError "self\(\.\l\+\)*\.\u\w\+(" display

