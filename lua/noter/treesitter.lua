local M = {}

--- Helper function to get the text content of a Tree-sitter node.
--- @param node table The Tree-sitter node.
--- @param bufnr integer The buffer number.
--- @return string The text represented by the node.
local function get_node_text(node, bufnr)
    return vim.treesitter.get_node_text(node, bufnr)
end

--- Scans a buffer using Tree-sitter to find all Zettelkasten-style [[links]].
--- This function is designed to find shortcut links, e.g., [[My Note]].
--- @param bufnr integer The buffer number to scan. Defaults to the current buffer.
--- @return table A list of the link texts found, e.g., { "My Note" }.
function M.get_links(bufnr)
    bufnr = bufnr or vim.api.nvim_get_current_buf()

    local ts = vim.treesitter
    local parsers = require('nvim-treesitter.parsers')

    local links = {}

    if not vim.api.nvim_buf_is_valid(bufnr) then return links end
    local mparser = parsers.get_parser(bufnr, 'markdown')
    if not mparser then
        vim.notify("NvimNoter: Markdown parser not available for this buffer.", vim.log.levels.WARN)
        return links
    end

    local inline_query = ts.query.parse('markdown', [[
    (inline) @inline
  ]])

    local shortcut_query = ts.query.parse('markdown_inline', [[
    (shortcut_link
      (link_text) @text
    )
  ]])

    local mtree = mparser:parse()[1]
    if not mtree then return links end
    local mroot = mtree:root()

    for _, inode, _ in inline_query:iter_captures(mroot, bufnr) do
        local start_row, _, end_row, _ = inode:range()
        for _, snode, _ in shortcut_query:iter_captures(inode, bufnr, start_row, end_row) do
            local text = get_node_text(snode, bufnr)
            table.insert(links, text)
        end
    end

    return links
end

return M
