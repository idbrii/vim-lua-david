local lume = require "lume"

local david = {}

local function is_valid_files_pat(pat, valid_paths)
    for _,path in ipairs(valid_paths) do
        if pat:find(path) then
            return true
        end
    end
end

function david.get_luacheck_globals(luacheckrc_fpath, valid_paths)
    valid_paths = valid_paths or {'data', 'scripts'}
    local fn, msg = loadfile(luacheckrc_fpath)
    if not fn then
        print("ERROR[get_luacheck_globals]", msg)
        return
    end

    -- intentionally global
    files, globals, read_globals = {}, {}, {}
    local cfg = fn() or {}
    cfg = lume.deep_merge(cfg, {
            files = files,
            globals = globals,
            read_globals = read_globals,
        })
    files, globals, read_globals = nil, nil, nil

    local globs = {}
    globs = lume.concat(globs, cfg.globals, cfg.read_globals)
    for key,settings in pairs(cfg.files) do
        if is_valid_files_pat(key, valid_paths) then
            globs = lume.concat(globs, settings.read_globals, settings.globals)
        end
    end
    return globs
end

local function test_get_globals()
    local pretty = require "inspect"
    local globs = david.get_luacheck_globals("C:/code/gamebox/.luacheckrc")
    print("globs =", pretty(globs, { depth = 5, }))
end

--~ test_get_globals()

return david
