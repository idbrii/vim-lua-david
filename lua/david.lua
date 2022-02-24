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
        print(msg)
        return
    end

    -- intentionally global
    files = {}
    fn()
    local globs = {}
    for key,settings in pairs(files) do
        if is_valid_files_pat(key, valid_paths) then
            globs = lume.concat(globs, settings.read_globals)
        end
    end
    files = nil
    return globs
end

local function test_get_globals()
    local pretty = require "inspect"
    local globs = david.get_luacheck_globals("C:/code/gamebox/.luacheckrc")
    print("globs =", pretty(globs, { depth = 5, }))
end

--~ test_get_globals()

return david
