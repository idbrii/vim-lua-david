local log = {}

local function BuildPathLookup(file_with_valid_names)
    local paths = {}
    for line in io.lines(file_with_valid_names) do
        local file = line:match("([^/\\]+%.lua)")
        if file then
            paths[file] = line
        end
        -- else: ignore cpp, etc files
    end
    return paths
end

-- When LUA_IDSIZE is shorter than the filename, lua truncates the filenames
-- with an ellipsis. Use a lookup file to undo that truncation. I've modified
-- luaO_chunkid so it outputs the end of the filepath instead of truncating the
-- most relevant part, so we're able to find the files here.
--
-- Caveat: Will replace with the first matching filename, so may be wrong when
-- there's duplicate names in different directories.
--
--- @param file_with_valid_names string: A listing of absolute paths.
--- @param log_filename string: The file to modify.
function log.ReplaceTruncatedFilenames(file_with_valid_names, log_filename)
    local paths
    local function LookupCorrectPath(path, filename)
        if filename then
            -- Lazily build paths.
            paths = paths or BuildPathLookup(file_with_valid_names)
            return paths[filename] or path
        end
    end

    local content = {}
    for line in io.lines(log_filename) do
        line = line:gsub("(%.%.%..-)([^./\\]+.lua)", LookupCorrectPath)
        table.insert(content, line)
    end

    local file = io.open(log_filename, "w")
    assert(file)
    for _, line in ipairs(content) do
        file:write(line)
        file:write("\n") -- lines() excludes newlines, but write doesn't add them.
    end
    file:close()
end

return log
