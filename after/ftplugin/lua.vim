
" See ~/.vim/scripts/buildtags for how lua tags are generated.
setlocal tags^=./lua.tags;/

" lua-xolox turns this on but I find it annoying.
setlocal fo-=o

" Lua uses lots of : so limit to known ones.
let b:openbrowser_allowed_schemes = get(g:, 'david_openbrowser_safe_schemes', [ 'http', 'https', ])

"" Quick commenting/uncommenting.
" ~ prefix from https://www.reddit.com/r/vim/comments/4ootmz/what_is_your_little_known_secret_vim_shortcut_or/d4ehmql
xnoremap <buffer> <silent> <C-o> :s/^/--\~ <CR>:silent nohl<CR>
xnoremap <buffer> <silent> <Leader><C-o> :s/^\([ \t]*\)--\~ /\1/<CR>:silent nohl<CR>

nnoremap <buffer> <Leader>ji :<C-u>NotGrep require.*\b<C-r>=expand('%:t:r')<CR>\b<CR>
" When files aren't required through normal means, just search for file name.
nnoremap <buffer> <Leader>jI :<C-u>NotGrep \b<C-r>=tolower(expand('%:t:r'))<CR>\b<CR>

" don't let lua-xolox clobber my map.
nnoremap <buffer> <F1> :<C-u>sp ~/.vim-aside<CR>
"inoremap <buffer> <F1> <Esc>

" lua-xolox's Omnicompletion in lua requires vim lua to load modules and I'm usually
" targetting a different lua. Can use tags instead (no scope intelligence, but
" better than nothing). Omnicompletion seems helpful in expanding modules, but
" that kicks in automatically, so that's good enough.
" Now, lua-ls provides completion, so use that default instead.
"~ inoremap <buffer> <C-Space> <C-x><C-]>

if get(g:, "lsp_loaded", 0) && lsp#get_server_status() =~# '\v<lua>.*running'
    setlocal omnifunc=lsp#complete
    " fall back to default omnicompletion
    iunmap <buffer> <C-Space>
endif

" Files may be opened with diff mode before this 'after' file is sourced.
" Ensure we don't clobber a more relevant mode.
if &foldmethod != 'diff'
    " Vim's lua syntax doesn't include fold information, so use indent instead.
    setlocal foldmethod=indent
endif

" Not ready to commit to stylua, so make it a separate command.
command! -range=% LuaHeavyDutyFixer <line1>,<line2> call david#lua#HeavyDutyFixer()


command! -buffer -nargs=* LuaLoveSetEntrypoint call david#lua#runner#set_entrypoint(david#lua#runner#GetLoveCmd() ..' --console % '.. <q-args>)
command! -buffer LuaSetEntrypoint call david#lua#runner#set_entrypoint('')


" Instead of calling here. Do in response to autocmd lsp_server_init.
"~ call david#lua#lsp#LoadConfigurationForWorkspace()
