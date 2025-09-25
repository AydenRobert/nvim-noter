local M = {}

local ts = vim.treesitter

-- Helpers

local function get_query(lang, name)
    -- Loads from runtimedir/queries/<lang>/<name>.scm
    local q = ts.query.get(lang, name)
    if not q then
        error(
            ("Tree-sitter query %q for language %q not found in runtimepath")
            :format(name, lang)
        )
    end
    return q
end

local function node_text(bufnr, node)
    return vim.treesitter.get_node_text(node, bufnr)
end

local function to_1based(line0)
    return (line0 or 0) + 1
end

local function trim(s)
    return (s:gsub("^%s+", ""):gsub("%s+$", ""))
end

local function strip_yaml_fences(text)
    -- Remove leading '---' line and trailing '---' or '...' line if present
    local lines = {}
    for line in tostring(text):gmatch("([^\r\n]*)\r?\n?") do
        if line == "" and #lines > 0 and lines[#lines] == "" then
            -- avoid trailing empty capture from gmatch; break when last is empty
            break
        end
        table.insert(lines, line)
    end

    if #lines == 0 then
        return ""
    end

    local start = 1
    local last = #lines
    if lines[start]:match("^%-%-%-%s*$") then
        start = start + 1
    end
    if last >= start and (lines[last]:match("^%-%-%-%s*$") or lines[last]:match("^%.%.%.%s*$")) then
        last = last - 1
    end

    local out = {}
    for i = start, last do
        table.insert(out, lines[i])
    end
    return table.concat(out, "\n")
end

local function classify_destination(dest)
    local s = trim(dest or "")
    -- Remove surrounding <> if present (CommonMark autolink style)
    s = s:gsub("^<", ""):gsub(">$", "")

    -- Detect scheme:// or scheme:
    local scheme = s:match("^([%a][%w%+%.%-]*):")
    if scheme then
        return {
            kind = "uri",
            scheme = scheme:lower(),
            destination = s,
        }
    end

    if s:match("^/") then
        return { kind = "absolute_path", destination = s }
    end
    if s:match("^%./") or s:match("^%.%./") then
        return { kind = "relative_path", destination = s }
    end

    -- Looks like a bare relative path or fragment
    if s:match("^#") then
        return { kind = "fragment", destination = s }
    end

    return { kind = "relative_path", destination = s }
end

-- Core extractors

-- Extract minus_metadata node text (front-matter) from a markdown buffer
function M.get_frontmatter_text(bufnr)
    bufnr = bufnr or vim.api.nvim_get_current_buf()
    local parser = ts.get_parser(bufnr, "markdown")
    local q = get_query("markdown", "captures")
    if parser == nil then
        error("Parser is nil, could not get frontmatter text")
    end
    local root = parser:parse()[1]:root()

    for id, node in q:iter_captures(root, bufnr, 0, -1) do
        local name = q.captures[id]
        if name == "metadata" and node:type() == "minus_metadata" then
            return strip_yaml_fences(node_text(bufnr, node))
        end
    end
    return nil
end

-- Parse front-matter YAML (as text) into a flat key->value map using the yaml query
function M.parse_yaml_pairs(yaml_text)
    if not yaml_text or yaml_text == "" then
        return {}
    end

    -- Use a scratch buffer-backed parser to leverage get_node_text neatly
    local scratch = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(scratch, 0, -1, false, vim.split(yaml_text, "\n", { plain = true }))

    local ok, parser = pcall(ts.get_parser, scratch, "yaml")
    if not ok then
        vim.api.nvim_buf_delete(scratch, { force = true })
        error("YAML parser is not available. Install nvim-treesitter parser for yaml.")
    end

    local q = get_query("yaml", "captures")
    if parser == nil then
        error("Parser is nil, could not get yaml pairs text")
    end
    local root = parser:parse()[1]:root()
    local map = {}

    for id, node in q:iter_captures(root, scratch, 0, -1) do
        local name = q.captures[id]
        if name == "pair" then
            -- We'll collect key/value children while we are inside this pair node
            local key_text, val_text
            for cid, child in q:iter_captures(node, scratch) do
                local cname = q.captures[cid]
                if cname == "pair.key" then
                    key_text = trim(node_text(scratch, child))
                elseif cname == "pair.value" then
                    val_text = trim(node_text(scratch, child))
                end
            end
            if key_text and key_text ~= "" then
                map[key_text] = val_text or ""
            end
        end
    end

    vim.api.nvim_buf_delete(scratch, { force = true })
    return map
end

-- Extract headings in order with 1-based line numbers
function M.get_headings(bufnr)
    bufnr = bufnr or vim.api.nvim_get_current_buf()
    local parser = ts.get_parser(bufnr, "markdown")
    local q = get_query("markdown", "captures")
    if parser == nil then
        error("Parser is nil, could not get headings text")
    end
    local root = parser:parse()[1]:root()

    local headings = {}
    for id, node in q:iter_captures(root, bufnr, 0, -1) do
        local name = q.captures[id]
        if name == "heading" then
            -- For atx_heading, the text is usually its subtree; simplest: take node text and trim
            local text = trim(node_text(bufnr, node))
            table.insert(headings, {
                text = text,
                line = to_1based(node:start()),
            })
        end
    end
    return headings
end

-- Extract links and images from markdown_inline and classify destinations
function M.get_links_and_images(bufnr)
    bufnr = bufnr or vim.api.nvim_get_current_buf()
    local parser = ts.get_parser(bufnr, "markdown_inline")
    local q = get_query("markdown_inline", "captures")
    if parser == nil then
        error("Parser is nil, could not get links and images")
    end
    local root = parser:parse()[1]:root()

    local out = {
        links = {},
        images = {},
        shortcuts = {},
    }

    -- We'll gather info while walking captures
    for id, node in q:iter_captures(root, bufnr, 0, -1) do
        local cap = q.captures[id]

        if cap == "link" then
            -- collect children for this inline_link node
            local item = { kind = "link" }
            for cid, child in q:iter_captures(node, bufnr) do
                local cname = q.captures[cid]
                if cname == "link.text" then
                    item.text = trim(node_text(bufnr, child))
                elseif cname == "link.destination" then
                    item.destination_raw = trim(node_text(bufnr, child))
                elseif cname == "link.title" then
                    item.title = trim(node_text(bufnr, child))
                end
            end
            if item.destination_raw then
                local cls = classify_destination(item.destination_raw)
                item.class = cls.kind
                item.scheme = cls.scheme
                item.destination = cls.destination
            end
            item.line = to_1based(node:start())
            table.insert(out.links, item)
        elseif cap == "image" then
            local item = { kind = "image" }
            for cid, child in q:iter_captures(node, bufnr) do
                local cname = q.captures[cid]
                if cname == "image.description" then
                    item.alt = trim(node_text(bufnr, child))
                elseif cname == "image.destination" then
                    item.destination_raw = trim(node_text(bufnr, child))
                elseif cname == "image.title" then
                    item.title = trim(node_text(bufnr, child))
                end
            end
            if item.destination_raw then
                local cls = classify_destination(item.destination_raw)
                item.class = cls.kind
                item.scheme = cls.scheme
                item.destination = cls.destination
            end
            item.line = to_1based(node:start())
            table.insert(out.images, item)
        elseif cap == "shortcut" then
            local item = { kind = "shortcut" }
            for cid, child in q:iter_captures(node, bufnr) do
                local cname = q.captures[cid]
                if cname == "shortcut.text" then
                    item.text = trim(node_text(bufnr, child))
                end
            end
            item.line = to_1based(node:start())
            table.insert(out.shortcuts, item)
        end
    end

    return out
end

-- Convenience: Process the current buffer and return a summary:
-- {
--   frontmatter = { key = value, ... },
--   headings = { { text, line }, ... },
--   links = { ... },
--   images = { ... },
--   shortcuts = { ... },
-- }
function M.analyze_buffer(bufnr)
    bufnr = bufnr or vim.api.nvim_get_current_buf()
    local yaml_text = M.get_frontmatter_text(bufnr)
    local frontmatter = M.parse_yaml_pairs(yaml_text or "")
    local headings = M.get_headings(bufnr)
    local li = M.get_links_and_images(bufnr)

    return {
        frontmatter = frontmatter,
        headings = headings,
        links = li.links,
        images = li.images,
        shortcuts = li.shortcuts,
    }
end

return M
