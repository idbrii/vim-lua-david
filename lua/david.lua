local lume = require "lume"

local david = {}

local function is_valid_files_pat(pat, valid_paths)
    for _,path in ipairs(valid_paths) do
        if pat:find(path) then
            return true
        end
    end
end

function david.get_luacheck_cfg(luacheckrc_fpath, valid_paths)
    valid_paths = valid_paths or {'data', 'scripts'}
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
    local cfg = david.get_luacheck_cfg(luacheckrc_fpath, valid_paths)

    local sumneko = {
        lua_version = "Lua 5.3",
        globals = {},
    }
    sumneko.globals = lume.concat(sumneko.globals, cfg.globals, cfg.read_globals)
    for key,settings in pairs(cfg.files) do
        if is_valid_files_pat(key, valid_paths) then
            sumneko.globals = lume.concat(sumneko.globals, settings.read_globals, settings.globals)
        end
    end

    local lua, major, minor = cfg.std:match("^(lua)(%d)(%d+)$")
    if minor then
        sumneko.lua_version = ("Lua %d.%d"):format(major, minor)
    elseif cfg.std:lower() == "luajit" then
        sumneko.lua_version = "LuaJIT"
    end
    return sumneko
end

local function test_get_luacheck()
    local pretty = require "inspect"
    local cfg = david.get_luacheck_cfg("C:/code/gamebox/.luacheckrc")
    print("cfg =", pretty(cfg, { depth = 5, }))
end

local function test_get_sumneko()
    local pretty = require "inspect"
    local cfg = david.get_sumneko_cfg_from_luacheck("C:/code/gamebox/.luacheckrc")
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
