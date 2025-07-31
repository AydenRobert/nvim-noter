local M = {}

function M.hello(opts)
    print("Hello from " .. opts.name .. "!")
end

return M
