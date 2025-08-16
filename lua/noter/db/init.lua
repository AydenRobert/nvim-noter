local M = {}

M.files = require('noter.db.files')
M.helper = require('noter.db.helper')

local lsqlite3 = require('lsqlite3')

local vars = require('noter.vars')

local datadir = '/home/ayden/workspace/github.com/AydenRobert/nvim-noter/'

function M.setup()
    vars.db = lsqlite3.open(datadir .. 'db.sqlite3')
    local sqlfile = io.open(datadir .. 'lua/noter/db/setup.sql')
    local sqlsetup
    if sqlfile then
        sqlsetup = sqlfile:read("*a")
        vars.db:exec(sqlsetup)
    end
end

function M.close()
    vars.db:close()
end

return M
