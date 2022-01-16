function! david#lua#setup_qf_after_compile() abort
    " No errors detected in lua, so keep it really small if no callstack.
    call fixquick#window#resize_qf_to_errorcount(5,20)
    " Testy usually shows assert failures first.
    call fixquick#window#show_first_error_without_jump()
endf

function! david#lua#setup_for_running() abort
    let g:asyncrun_exit = 'call david#lua#setup_qf_after_compile()'

    " Run to execute and make to test.
    "
    " luatesty expects functions called test_[name of another function]()
    " install with `luarocks install testy`
    command! ProjectRun  compiler lua      | update | call david#path#chdir_to_current_file() | AsyncMake
    command! ProjectMake compiler luatesty | update | call david#path#chdir_to_current_file() | AsyncMake
endf

function! david#lua#run_with(compiler) abort
    let g:asyncrun_exit = 'call david#lua#setup_qf_after_compile()'

    " Run to execute and make to test.
    "
    " luatesty expects functions called test_[name of another function]()
    " install with `luarocks install testy`
    exec 'compiler' a:compiler
    update
    if exists('g:david_lua_testy_chdir')
        exec g:david_lua_testy_chdir
    else
        call david#path#chdir_to_current_file()
    endif
    AsyncMake
endf

function! david#lua#HeavyDutyFixer() range abort
    if a:firstline == 1 && a:lastline == line('$')
        call david#lua#HeavyDutyFixer_wholefile()
    else
        call david#lua#HeavyDutyFixer_range(a:firstline, a:lastline)
    endif
endf

function! david#lua#HeavyDutyFixer_wholefile() abort
    call add(g:ale_fixers.lua, 'stylua')
    ALEFix
    call remove(g:ale_fixers.lua, index(g:ale_fixers.lua, 'stylua'))
endf


" ALEFix only operates on a whole file. Use NrrwRgn to limit to selection.
function! david#lua#HeavyDutyFixer_range(startline, endline) abort
    let lazyredraw_bak = &lazyredraw
    let &lazyredraw = 1
    
    exec printf("%d,%d NR", a:startline, a:endline)
    call david#lua#HeavyDutyFixer_wholefile() 
    
    " Can't auto close the region because ALEFix isn't synchronous and it gives
    " errors: "The file was changed before fixing finished"

    let &lazyredraw = lazyredraw_bak
endf

" Callback after running ALEFix. See :h ale-fix
function! david#lua#ale_fix_cb(buffer, output) abort
    let lines = []
    let prefix = ""
    let shift = "\t"
    if &expandtab
        let shift = '    '
    endif
    
    for line in a:output
        " Use my preferred require format.
        let line = substitute(line, '\vrequire\((.*)\)', 'require \1', "")
        " Keep :AddChild on same line since rest of chains are applying to a
        " different object.
        if line =~# '\v^\s+:AddChild'
            let prev = lines->remove(-1)
            let prev = substitute(prev, '\s*$', '', '')
            let line = substitute(line, '^\s*', '', '')
            let line = prev .. line
        elseif line =~# '\v\)\zs:\u'
            " Put repeated function chaining on a separate line. Puts f():g()
            " or s:f():g() on two lines -- s:f() shouldn't get split up.
            let indent = matchstr(line, '\v^\s*')
            let prefix = shift .. indent
            let sep = '):'

            let parts = line->split(sep)
            let line = parts[0] .. ')'
            let parts = parts[1:]
            let parts = parts->map({k,v -> ':'.. v .. ')'})
            " These seems unnecessary.
            "~ if parts[0] =~# '\v<AddChild>'
            "~     let line .= sep.. parts[0]
            "~     let parts = parts[1:]
            "~ endif
            call add(lines, line)
            for p in parts[:-2]
                call add(lines, prefix .. p)
            endfor
            " Last line, without the extra ) I added
            let line = prefix .. parts[-1][:-2]
        endif
        call add(lines, line)
    endfor
    return lines
endf

