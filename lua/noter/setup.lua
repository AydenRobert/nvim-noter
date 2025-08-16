local db = require('noter.db')
local file_tracker = require('noter.file_tracker')
local files = require('noter.files')

local M = {}

function M.on_nvim_open(args)
    local currentdir = vim.fn.getcwd()
    if currentdir ~= "/home/ayden/workspace/github.com/AydenRobert/second_brain" then
        return
    end

    db.setup()
    file_tracker.lazy_scan_all()
    files.sync_db()
end

return M
