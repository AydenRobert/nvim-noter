local meta = require("noter.metadata")

vim.api.nvim_create_user_command("MarkdownAnalyze", function(_)
  local result = meta.analyze_buffer(0)
  print(vim.inspect(result))
end, { nargs = 0 })
