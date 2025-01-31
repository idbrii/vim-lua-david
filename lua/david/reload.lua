local reload = {}

function reload.UnloadMatching(name_regex)
    -- https://stackoverflow.com/a/72504767/79125
    -- Clear all my modules and reload my nvim config.
    for name,_ in pairs(package.loaded) do
        if name:match(name_regex) then
            package.loaded[name] = nil
        end
    end
end

function reload.ReloadAll()
    reload.UnloadMatching("^david")

    -- Avoid my warning about unnecessary work.
    vim.cmd.unlet({"did_load_filetypes", bang = true})

    dofile(vim.env.MYVIMRC)
    vim.notify("nvim configuration reloaded!", vim.log.levels.INFO)
end

return reload
