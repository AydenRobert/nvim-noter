local function on_md_create(args)
    local filename = vim.fn.expand('%')
    vim.print(filename)
end

vim.api.nvim_create_autocmd(
    'BufNew',
    {
        pattern = "*.md",
        callback = function(args) on_md_create(args) end,
        desc = "this is a test autocommand"
    }
)
