let s:cache_luacheck_globs = {}
let s:cache_luacheck_workspaces = {}

function! david#lua#lsp#GetLuacheckrc() abort
    let rcfile = david#path#find_upwards_from_current_file(".luacheckrc")
    if empty(rcfile)
        return ""
    endif
    return david#path#to_unix(rcfile)
endf
function! david#lua#lsp#GetGlobalsFromLuacheckrc(rcfile) abort
    lua david = require "david"
    let cmd = printf("vim.list(david.get_luacheck_globals('%s', {'data', 'scripts'}))", a:rcfile)
    let globs = luaeval(cmd)
    let s:cache_luacheck_globs[a:rcfile] = globs
    return globs
endf

function! david#lua#lsp#LoadConfigurationForWorkspace() abort
    let servername = 'sumneko-lua-language-server'
    if lsp#get_server_status(servername) !=# 'running'
        return
    endif
    let rcfile = david#lua#lsp#GetLuacheckrc()
    let already_applied = get(s:cache_luacheck_workspaces, rcfile, 0)
    if already_applied
        return
    endif
    let s:cache_luacheck_workspaces[rcfile] = 1

    try
        let globals = david#lua#lsp#GetGlobalsFromLuacheckrc(rcfile)
    catch /^Vim\%((\a\+)\)\=:E370/	" Error: Could not load library lua53.dll
        let globals = [""]
    endtry
    let cfg = {
                \            'Lua': {
                \                'diagnostics': {
                \                    'globals': globals,
                \                    },
                \                'telemetry': {
                \                    'enable': v:true,
                \                    },
                \                },
                \        }
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
                \        'cache_luacheck_globs': s:cache_luacheck_globs,
                \        'cache_luacheck_workspaces': s:cache_luacheck_workspaces,
                \    })
    
endf

