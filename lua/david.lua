local lume = require "lume"

local david = {}

local default_valid_paths = {'data', 'scripts'}

local function is_valid_files_pat(pat, valid_paths)
    for _,path in ipairs(valid_paths) do
        if pat:find(path) then
            return true
        end
    end
end

function david.get_luacheck_cfg(luacheckrc_fpath, valid_paths)
    valid_paths = valid_paths or default_valid_paths
    local fn, msg = loadfile(luacheckrc_fpath)
    if not fn then
        print("ERROR[get_luacheck_cfg]", msg)
        return
    end

    -- intentionally global
    std = 'luajit'
    files, globals, read_globals = {}, {}, {}
    local cfg = fn() or {}
    cfg = lume.deep_merge(cfg, {
            std = std,
            files = files,
            globals = globals,
            read_globals = read_globals,
        })
    std, files, globals, read_globals = nil, nil, nil, nil
    return cfg
end

function david.get_sumneko_cfg_from_luacheck(luacheckrc_fpath, valid_paths)
    valid_paths = valid_paths or default_valid_paths
    local cfg = david.get_luacheck_cfg(luacheckrc_fpath, valid_paths)
    if not cfg then
        return
    end

    -- Collect data from luacheck config.
    local check_cfg = {
        lua_version = "Lua 5.3",
        globals = {},
    }
    check_cfg.globals = lume.concat(check_cfg.globals, cfg.globals, cfg.read_globals)
    for key,settings in pairs(cfg.files) do
        if is_valid_files_pat(key, valid_paths) then
            check_cfg.globals = lume.concat(check_cfg.globals, settings.read_globals, settings.globals)
        end
    end

    local lua, major, minor = cfg.std:match("^(lua)(%d)(%d+)$")
    if minor then
        check_cfg.lua_version = ("Lua %d.%d"):format(major, minor)
    elseif cfg.std:lower() == "luajit" then
        check_cfg.lua_version = "LuaJIT"
    end

    local lsp_cfg = {
        Lua = {
            runtime = {
                version = check_cfg.lua_version,
            },
            diagnostics = {
                globals = check_cfg.globals,
                unusedLocalExclude = {"test_*", "_*"},
            },
            telemetry = {
                enable = true,
            },
        },
    }

    -- Prevent love detection nag: lua-language-server#679
    -- and preload nag: lua-language-server#1594
    lsp_cfg.Lua.workspace = {
        checkThirdParty = false,
        maxPreload = 100000,
        ignoreDir = {".git", ".svn", ".vs"}
    }

    local ignored_diagnostics = {
        "lowercase-global",
        "undefined-global",
        "trailing-space",  -- I lost the war
        "unused-local",  -- triggers for arguments
    }
    lsp_cfg.Lua.diagnostics.disable = ignored_diagnostics
    -- Disabling individual diagnostics disabled all diagnostics before, but
    -- maybe doesn't anymore? Could also try enabling:
    --~ lsp_cfg.Lua.diagnostics.enable = true

    -- All luacheck diagnostics are severity 2, but can control luals here.
    --~ lsp_cfg.Lua.diagnostics.groupSeverity = {
    --~     unused = "Information",
    --~ }

    return lsp_cfg
end

local function test_get_luacheck()
    local pretty = require "inspect"
    local cfg = david.get_luacheck_cfg("C:/code/love-fun-kit/.luacheckrc")
    print("cfg =", pretty(cfg, { depth = 5, }))
end

local function test_get_sumneko()
    local pretty = require "inspect"
    local cfg = david.get_sumneko_cfg_from_luacheck("C:/code/love-fun-kit/.luacheckrc")
    print("cfg =", pretty(cfg, { depth = 5, }))
end

-- vim.dict can't convert nested tables ("cannot convert value"), so implement
-- it ourselves.
function david.dict(t)
    local v = t
    if type(v) == "table" then
        if v[1] then
            v = vim.list()
            for key,val in ipairs(t) do
                v[key] = david.dict(val)
            end
        else
            v = vim.dict()
            for key,val in pairs(t) do
                v[key] = david.dict(val)
            end
        end
    end
    return v
end

--~ test_get_sumneko()

return david
