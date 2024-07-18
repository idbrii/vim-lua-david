let s:cache_luacheck_cfg = {}
let s:cache_luacheck_workspace = ""

function! david#lua#lsp#GetLuacheckrc() abort
    let rcfile = david#path#find_upwards_from_current_file(".luacheckrc")
    if empty(rcfile)
        return ""
    endif
    return david#path#to_unix(fnamemodify(rcfile, ":p"))
endf
function! david#lua#lsp#BuildConfigFromLuacheckrc_uncached(rcfile) abort
    lua david = require "david"
    let cmd = printf("david.dict(david.get_sumneko_cfg_from_luacheck('%s', {'data', 'scripts'}))", a:rcfile)
    let cfg = luaeval(cmd)
    return cfg
endf

function! david#lua#lsp#BuildConfigFromLuacheckrc(...) abort
    let rcfile = david#lua#lsp#GetLuacheckrc()
    if !filereadable(rcfile)
        return
    endif

    let force = (!empty(a:000) && a:1 == "force")
    let already_applied = s:cache_luacheck_workspace == rcfile
    if already_applied && !force
        return
    endif

    let cfg = get(s:cache_luacheck_cfg, rcfile, {})
    try
        if force || empty(cfg)
            let cfg = david#lua#lsp#BuildConfigFromLuacheckrc_uncached(rcfile)
            let s:cache_luacheck_cfg[rcfile] = cfg
            let s:cache_luacheck_workspace = rcfile
        endif
    catch /^Vim\%((\a\+)\)\=:E370/	" Error: Could not load library lua53.dll
        let cfg = {
                \            'Lua': {
                \                'runtime' : {
                \                    'version': 'LuaJIT',
                \                },
                \                'diagnostics': {
                \                    'unusedLocalExclude' : ["test_*", "_*"],
                \                },
                \                'telemetry': {
                \                    'enable': v:true,
                \                },
                \            },
                \        }
    endtry

    return cfg
endf

function! david#lua#lsp#LoadConfigurationForWorkspace(...) abort
    let servername = 'sumneko-lua-language-server'
    if lsp#get_server_status(servername) !=# 'running'
        return
    endif
    let cfg = david#lua#lsp#BuildConfigFromLuacheckrc(...)
    call lsp#update_workspace_config(servername, cfg)
endf

function! david#lua#lsp#PrintState() abort
    call scriptease#pp_command(0, -1, {
                \        'cache_luacheck_cfg': s:cache_luacheck_cfg,
                \        'cache_luacheck_workspace': s:cache_luacheck_workspace,
                \    })
    
endf

