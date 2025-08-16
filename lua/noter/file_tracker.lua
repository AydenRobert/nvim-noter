local M = {}

local db = require('noter.db')
local vars = require('noter.vars')

function M.get_all_paths()
    local mdpaths = vim.fs.find(
        function(name)
            return name:match('.*%.md$')
        end,
        {
            type = 'file',
            limit = math.huge
        }
    )
    local mdnames = {}
    for _, mdpath in ipairs(mdpaths) do
        mdnames[#mdnames + 1] = vim.fn.fnamemodify(mdpath, ':t:r')
    end
    return mdpaths
end

function M.get_file_differences(mdpaths, db_mdpaths)
    local all_paths = {}

    for _, path in ipairs(mdpaths) do
        all_paths[path] = "in_md_only"
    end

    for _, path in ipairs(db_mdpaths) do
        if all_paths[path] == "in_md_only" then
            all_paths[path] = "in_both"
        else
            all_paths[path] = "in_db_only"
        end
    end

    local in_md_only = {}
    local in_db_only = {}

    for path, status in pairs(all_paths) do
        if status == "in_md_only" then
            table.insert(in_md_only, path)
        elseif status == "in_db_only" then
            table.insert(in_db_only, path)
        end
    end

    return in_md_only, in_db_only
end

local function scan()
    local mdpaths = M.get_all_paths()
    local db_mdpaths = db.files.get_all_filepaths()

    return mdpaths, db_mdpaths
end

function M.lazy_scan_all()
    local mdpaths, db_mdpaths = scan()
    vars.unknown_paths, vars.out_of_sync_paths = M.get_file_differences(mdpaths, db_mdpaths)
end

function M.full_scan_all()
    local mdpaths, db_mdpaths = scan()
    vars.unknown_paths = mdpaths
    _, vars.out_of_sync_paths = M.get_file_differences(mdpaths, db_mdpaths)
end

return M
