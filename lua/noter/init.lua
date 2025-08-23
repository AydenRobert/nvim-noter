local function setup()
  require('nvim-noter.core').scan_workspace()
end

local augroup = vim.api.nvim_create_augroup('NvimNoter', { clear = true })

vim.api.nvim_create_autocmd('VimEnter', {
  group = augroup,
  pattern = '*',
  callback = function()
    vim.defer_fn(setup, 0)
  end,
})

vim.api.nvim_create_autocmd('BufWritePost', {
  group = augroup,
  pattern = '*.md',
  callback = function(args)
    require('nvim-noter.core').update_file(args.buf)
  end,
})

vim.api.nvim_create_autocmd('BufNewFile', {
    group = augroup,
    pattern = '*.md',
    callback = function(args)
        print("NvimNoter: New note created!")
    end
})
