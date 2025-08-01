vim.api.nvim_create_autocmd(
    'BufNew',
    {
        pattern = "*.md",
        callback = function() print("This is a callback") end,
        desc = "this is a test autocommand"
    }
)

local M = {}

function M.hello(opts)
    print("Hello from " .. opts.name .. "!")
end

return M
