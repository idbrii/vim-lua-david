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
