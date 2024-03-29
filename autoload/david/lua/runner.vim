
" Global entrypoint
function! david#lua#runner#set_entrypoint(makeprg)
    " Use the current file and its directory and jump back there to run
    " (ensures any expected relative paths will work).
    let cur_file = david#path#to_unix('%:p')
    let cur_dir = david#path#to_unix(fnamemodify(cur_file, ':h'))
    let cur_module = david#path#to_unix(fnamemodify(cur_file, ':t:r'))

    if !exists("b:david_lua_original_makeprg")
        let b:david_lua_original_makeprg = &makeprg
    endif

    if a:makeprg =~# '^lovec\?\>'
        " Don't have a better way to distinguish love files, so use this to
        " configure checker properly.
        let g:ale_lua_luacheck_options .= ' --std love+luajit'
        let target = cur_dir

        " TODO: Should parse conf.lua to see if we call setRequirePath, but
        " this is fine for now.
        let $LUA_PATH     = $LUA_PATH     ..";src/?.lua;src/?/init.lua;src/lib/?.lua;src/lib/?/init.lua"
        let $LUA_PATH_5_3 = $LUA_PATH_5_3 ..";src/?.lua;src/?/init.lua;src/lib/?.lua;src/lib/?/init.lua"

        " Gabe uses S for a global.
        let g:vim_lsp_settings_sumneko_lua_language_server_workspace_config.Lua.diagnostics.globals = 'S'
    else
        let target = cur_file
    endif
    
    let entrypoint_makeprg = a:makeprg
    if empty(a:makeprg)
        let entrypoint_makeprg = b:david_lua_original_makeprg
    endif
    let entrypoint_makeprg = substitute(entrypoint_makeprg, '%', target, '')

    function! DavidProjectBuild() closure
        update
        ProjectKill
        " Wait long enough for app to close and asyncrun to terminate so
        " it doesn't fail to run again.
        sleep 1
        call execute('lcd '. cur_dir)
        let &makeprg = entrypoint_makeprg
        " Use AsyncRun instead of AsyncMake so we can pass cwd and ensure
        " callstacks are loaded properly.
        execute 'AsyncRun -program=make -auto=make -cwd='. cur_dir .' @'
    endf
    " Don't let python settings leak into lua.
    let g:asyncrun_exit = ''

    command! ProjectMake call david#lua#run_with('luatesty')
    command! ProjectRun  call DavidProjectBuild()
    let &makeprg = entrypoint_makeprg
    exec david#path#build_kill_from_current_makeprg()

    " Clobber current project settings.
    silent! unlet g:david_project_filelist
    let g:david_project_root = fnamemodify(cur_file, ':h')
    let g:david_lua_testy_chdir = 'cd '.. cur_dir
    LocateAllTagFiles
    NotGrepRecursiveFrom .
    " I put code in ./src/
    let g:inclement_n_dir_to_trim = 2
    let g:inclement_after_first_include = 1
    let g:inclement_include_directories = "lib|src"
    " Must match tags file which uses no drive and forward slashes

    let src_root = g:david_project_root ..'/src/'
    if has('win32')
        let src_root = substitute(src_root, '\\', '/', 'g')
        let src_root = substitute(src_root, '^\w:', '', '')
    endif
    let g:inclement_src_root = src_root
endf
function! david#lua#runner#GetLoveCmd()
    if has('win32')
        " Lovec does a better job of outputting to the console on Windows.
        return 'lovec'
    else
        return 'love'
    endif
endf
