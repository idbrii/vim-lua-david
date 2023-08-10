let s:cache_luacheck_cfg = {}
let s:cache_luacheck_workspace = ""

function! david#lua#lsp#GetLuacheckrc() abort
    let rcfile = david#path#find_upwards_from_current_file(".luacheckrc")
    if empty(rcfile)
        return ""
    endif
    return david#path#to_unix(fnamemodify(rcfile, ":p"))
endf
function! david#lua#lsp#GetGlobalsFromLuacheckrc(rcfile) abort
    lua david = require "david"
    let cmd = printf("david.dict(david.get_sumneko_cfg_from_luacheck('%s', {'data', 'scripts'}))", a:rcfile)
    let cfg = luaeval(cmd)
    return cfg
endf

function! david#lua#lsp#LoadConfigurationForWorkspace(...) abort
    let servername = 'sumneko-lua-language-server'
    if lsp#get_server_status(servername) !=# 'running'
        return
    endif
    let rcfile = david#lua#lsp#GetLuacheckrc()
    if !filereadable(rcfile)
        return
    endif

    let force = (!empty(a:000) && a:1 == "force")
    let already_applied = s:cache_luacheck_workspace == rcfile
    if already_applied && !force
        return
    endif

    let check_cfg = get(s:cache_luacheck_cfg, rcfile, {})
    try
        if force || empty(check_cfg)
            let check_cfg = david#lua#lsp#GetGlobalsFromLuacheckrc(rcfile)
            let s:cache_luacheck_cfg[rcfile] = check_cfg
            let s:cache_luacheck_workspace = rcfile
        endif
    catch /^Vim\%((\a\+)\)\=:E370/	" Error: Could not load library lua53.dll
        let check_cfg = { 'lua_version': 'LuaJIT', 'globals': "" }
    endtry

    " When I upgrade sumneko, try this:
                "\                    'unusedLocalExclude' : ["test_*", "_*"],
    let cfg = {
                \            'Lua': {
                \                'runtime' : {
                \                    'version' : check_cfg.lua_version,
                \                },
                \                'diagnostics': {
                \                    'globals': check_cfg.globals,
                \                },
                \                'telemetry': {
                \                    'enable': v:true,
                \                    },
                \                },
                \        }

    " Prevent love detection nag: lua-language-server#679
    " and preload nag: lua-language-server#1594
    let cfg.Lua.workspace = {
                \         'checkThirdParty' : v:false,
                \         'maxPreload' : 10000,
                \ }

    " For some reason, disabling individual diagnostics disables all
    " diagnostics.
    "~ let ignored_diagnostics = [
    "~             \    'lowercase-global', 
    "~             \    'undefined-global',
    "~             \]
    "~ let cfg.Lua.diagnostics.disable = ignored_diagnostics

    call lsp#update_workspace_config(servername, cfg)
endf

function! david#lua#lsp#PrintState() abort
    call scriptease#pp_command(0, -1, {
                \        'cache_luacheck_cfg': s:cache_luacheck_cfg,
                \        'cache_luacheck_workspace': s:cache_luacheck_workspace,
                \    })
    
endf

