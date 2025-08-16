local db = require('noter.db')
local vars = require('noter.vars')

local M = {}

function M.on_md_create(args)
    -- local file = M.create_file_table(args.file)
    -- M.register_file(file)
end

function M.create_file_table(mdpath)
    local filedata = vim.loop.fs_stat(mdpath)
    local file = {}
    file.filepath = mdpath
    file.filename = vim.fn.fnamemodify(mdpath, ':t:r')
    file.lastChecked = filedata.mtime.sec
    return file
end

function M.create_file_tables(mdpaths)
    local files = {}
    for _, mdpath in ipairs(mdpaths) do
        local filedata = vim.loop.fs_stat(mdpath)
        local file = {}
        file.filepath = mdpath
        file.filename = vim.fn.fnamemodify(mdpath, ':t:r')
        file.lastChecked = filedata.mtime.sec
        files[#files + 1] = file
    end
    return files
end

function M.register_file(file)
    db.files.insert_file(file)
end

function M.sync_db()
    db.files.remove_files_from_paths(vars.out_of_sync_paths)
    local unknown_files = M.create_file_tables(vars.unknown_paths)
    db.files.insert_files(unknown_files)
    vars.unknown_paths = {}
    vars.out_of_sync_paths = {}
end

return M
