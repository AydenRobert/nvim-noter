-- get_shortcut_links.lua

local api     = vim.api
local ts      = vim.treesitter
local parsers = require('nvim-treesitter.parsers')

-- Get current buffer and its markdown parser
local bufnr    = api.nvim_get_current_buf()
local mparser  = parsers.get_parser(bufnr, 'markdown')
if not mparser then
  return
end

-- Parse and grab the root
local mtree = mparser:parse()[1]
local mroot = mtree:root()

-- Query to grab every "inline" node in the markdown tree
local inline_query = ts.query.parse('markdown', [[
  (inline) @inline
]])

-- Query to find shortcut_link → link_text in an inline snippet
local shortcut_query = ts.query.parse('markdown_inline', [[
  (shortcut_link
     (link_text) @text
  )
]])

-- Utility: pull text from the main buffer for a node
local function get_buf_text(node)
  local sr, sc, er, ec = node:range()
  local lines = api.nvim_buf_get_text(bufnr, sr, sc, er, ec, {})
  return table.concat(lines, '\n')
end

-- Utility: extract a sub-string from a snippet given a node range
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

-- 1) Iterate all (inline) nodes in the markdown parse
for _, inode, _ in inline_query:iter_captures(mroot, bufnr, 0, -1) do
  -- 2) Grab its raw text from the buffer
  local snippet = get_buf_text(inode)

  -- 3) Re-parse that snippet as markdown_inline
  local siparser = ts.get_string_parser(snippet, 'markdown_inline')
  if not siparser then
    goto continue
  end

  local stree = siparser:parse()[1]
  local sroot = stree:root()

  -- 4) Find all shortcut_link→link_text in this snippet
  for _, snode, _ in shortcut_query:iter_captures(sroot, 0, 0, -1) do
    local sr, sc, er, ec = snode:range()
    local text = slice_snippet(snippet, sr, sc, er, ec)
    print(text)
  end

  ::continue::
end
