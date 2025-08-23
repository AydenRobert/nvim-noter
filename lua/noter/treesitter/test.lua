local api     = vim.api
local ts      = vim.treesitter
local parsers = require('nvim-treesitter.parsers')

local bufnr    = api.nvim_get_current_buf()
local mparser  = parsers.get_parser(bufnr, 'markdown')
if not mparser then
  return
end

local mtree = mparser:parse()[1]
local mroot = mtree:root()

local inline_query = ts.query.parse('markdown', [[
  (inline) @inline
]])

local shortcut_query = ts.query.parse('markdown_inline', [[
  (shortcut_link
     (link_text) @text
  )
]])

local function get_buf_text(node)
  local sr, sc, er, ec = node:range()
  local lines = api.nvim_buf_get_text(bufnr, sr, sc, er, ec, {})
  return table.concat(lines, '\n')
end

local function slice_snippet(snip, sr, sc, er, ec)
  local lines = vim.split(snip, '\n')
  local out = {}
  for row = sr, er do
    local line = lines[row + 1]
    if sr == er then
      out[#out+1] = line:sub(sc+1, ec)
    elseif row == sr then
      out[#out+1] = line:sub(sc+1)
    elseif row == er then
      out[#out+1] = line:sub(1, ec)
    else
      out[#out+1] = line
    end
  end
  return table.concat(out, '\n')
end

for _, inode, _ in inline_query:iter_captures(mroot, bufnr, 0, -1) do
  local snippet = get_buf_text(inode)

  local siparser = ts.get_string_parser(snippet, 'markdown_inline')
  if not siparser then
    goto continue
  end

  local stree = siparser:parse()[1]
  local sroot = stree:root()

  for _, snode, _ in shortcut_query:iter_captures(sroot, 0, 0, -1) do
    local sr, sc, er, ec = snode:range()
    local text = slice_snippet(snippet, sr, sc, er, ec)
    print(text)
  end

  ::continue::
end
