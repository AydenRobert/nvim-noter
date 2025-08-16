local vars = require('noter.vars')

local M = {}

-- helper
function M.get_all_tables()
    local tablenames = {}
    vars.db:exec(
        "SELECT name FROM sqlite_master WHERE type='table';",
        function(_, _, values, _)
            tablenames[#tablenames + 1] = values[1]
            return 0
        end,
        'udata'
    )
    return tablenames
end

-- helper
function M.drop_table(table)
    vars.db:exec("DROP TABLE IF EXISTS " .. table .. ";")
end

return M
