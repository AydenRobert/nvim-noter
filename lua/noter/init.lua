local setup = require('noter.setup')
local cleanup = require('noter.cleanup')
local files = require('noter.files')

vim.api.nvim_set_hl(0, "@shortcut.link.test", { bg = "#550000" })

vim.api.nvim_create_autocmd(
    'BufNewFile',
    {
        pattern = "*.md",
        callback = function(args) files.on_md_create(args) end,
        desc = "this is a test autocommand"
    }
)

vim.api.nvim_create_autocmd(
    'VimEnter',
    {
        callback = function(args) setup.on_nvim_open(args) end,
        desc = ""
    }
)

vim.api.nvim_create_autocmd(
    'VimLeavePre',
    {
        callback = function(args) cleanup.on_nvim_leave(args) end
    }
)
