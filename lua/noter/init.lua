local function on_md_create(args)
    vim.print(args.buf)
    vim.print(args.file)
    vim.print(args.match)
end

vim.api.nvim_create_autocmd(
    'BufNew',
    {
        pattern = "*.md",
        callback = function(args) on_md_create(args) end,
        desc = "this is a test autocommand"
    }
)
