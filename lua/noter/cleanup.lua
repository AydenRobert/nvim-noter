local db = require('noter.db')

local M = {}

function M.on_nvim_leave(args)
    local currentdir = vim.fn.getcwd()
    if currentdir ~= "/home/ayden/workspace/github.com/AydenRobert/second_brain" then
        return
    end
    -- for _, tablename in ipairs(db.helper.get_all_tables()) do
    --     db.helper.drop_table(tablename)
    -- end
    db.close()
end

return M
