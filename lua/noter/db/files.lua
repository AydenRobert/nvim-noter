local M = {}

local vars = require('noter.vars')
local lsqlite3 = require('lsqlite3')

function M.insert_file(file)
    local stmt = vars.db:prepare(
        "INSERT INTO files (filepath, filename, lastChecked) VALUES (?, ?, ?);"
    )
    if stmt then
        stmt:bind(1, file.filepath)
        stmt:bind(2, file.filename)
        stmt:bind(3, tostring(file.lastChecked))
        stmt:step()
        stmt:finalize()
    end
end

function M.insert_files(files)
    vars.db:exec("BEGIN TRANSACTION")
    local stmt = vars.db:prepare(
        "INSERT INTO files (filepath, filename, lastChecked) VALUES (?, ?, ?);"
    )

    if not stmt then
        vars.db:exec("ROLLBACK")
        return
    end

    for _, file in ipairs(files) do
        stmt:bind(1, file.filepath)
        stmt:bind(2, file.filename)
        stmt:bind(3, tostring(file.lastChecked))

        local rc = stmt:step()

        if rc ~= lsqlite3.DONE then
            local db_err = vars.db:errmsg()
            stmt:finalize()
            vars.db:exec("ROLLBACK")
            vim.print(db_err)
            return
        end

        stmt:reset()
    end
    stmt:finalize()
    vars.db:exec("COMMIT")
end

function M.check_file_path(mdpath)
    local stmt = vars.db:prepare(
        "SELECT filepath FROM files WHERE filepath = ?"
    )
    if stmt then
        stmt:bind(1, mdpath)
        stmt:set()
        stmt:finalize()
    else
        return nil, "Could not execute prepared statement for path: " .. mdpath
    end

    if #stmt:get_values() == 1 then
        return true, nil
    else
        return false, nil
    end
end

function M.get_all_files()
    local files = {}
    vars.db:exec(
        "SELECT * FROM files",
        function(_, _, values, _)
            local file = {}
            file.filepath = values[1]
            file.filename = values[1]
            file.lastChecked = values[3]
            files[#files+1] = file
        end
    )
    return files
end

function M.remove_files_from_paths(mdpaths)
    vars.db:exec("BEGIN TRANSACTION")
    local stmt = vars.db:prepare(
        "DELETE FROM files WHERE filepath = ?"
    )
    if not stmt then
        vars.db:exec("ROLLBACK")
        return
    end

    for _, mdpath in ipairs(mdpaths) do
        if stmt then
            stmt:bind(1, mdpath)
            stmt:step()
            stmt:reset()
        end
    end

    stmt:finalize()
    vars.db:exec("COMMIT")
end

function M.get_all_filepaths()
    local mdpaths = {}
    vars.db:exec(
        "SELECT filepath FROM files;",
        function(_, _, values, _)
            mdpaths[#mdpaths + 1] = values[1]
            return 0
        end
    )
    return mdpaths
end

return M
