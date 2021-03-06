
function! david#lua#search#FindUnusedModules() abort
    " Find lua modules that aren't `require`d anywhere. Great for cleaning up
    " love2d superprojects before publishing to limit to the actual project.
    "
    " depends on vim-notgrep, vim-searchsavvy, vim-bbye, and daveconfig.

    let lazyredraw_bak = &lazyredraw
    let &lazyredraw = 1
    let maxmempattern_bak = &maxmempattern
    let &maxmempattern = max([&maxmempattern, 5000])
    
    tabnew

    let allow_async_bak = g:notgrep_allow_async
    let g:notgrep_allow_async = 0


    NotGrep \brequire\b

    let g:notgrep_allow_async = allow_async_bak

    copen
    silent %yank c
    silent Scratch
    silent 0put c
    silent %v/\.lua|/d
    silent %g/| --/d
    silent %v/\v.*\s*<require\s*\(?(["'])(.*)\1\)?.*/d
    silent %sm//\2
    silent %s,\.,/,g
    silent %SearchForAnyLine
    silent let @c = @/
    silent Bwipeout
    " Special case some massive libraries
    let massive = { 'astray' : 0, 'cpml' : 0, 'maze' : 0, 'pl' : 0, }
    for key in keys(massive)
        let massive[key] = search('\v<'.. key ..'>', 'nw') > 0
    endfor

    cnext
    EditUpwards filelist
    v/^src.*lua$/d _
    let @/ = @c
    g//d _
    for key in keys(massive)
        if massive[key]
            exec "g,\\v<lib>.".. key ..",d _"
        endif
    endfor

    %argdelete
    g/^/exec 'argadd' getline('.')

    edit!
    tabclose

    nnoremap \\ :Gremo <Bar> next<CR>

    let &lazyredraw = lazyredraw_bak
    let &maxmempattern = maxmempattern_bak
    redraw

    echo "Unused modules loaded to arglist:"
    args
    echo 'Use \\ to delete current file and check next.'
endf
