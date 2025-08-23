local M = {}

function M.scan_workspace()
    print("NvimNoter: Scanning workspace...")
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

return M
