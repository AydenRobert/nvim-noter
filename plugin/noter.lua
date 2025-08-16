local noter = require('noter')

vim.api.nvim_create_user_command(
    'TestCommand',
    function(opts)
        print("hello")
    end,
    {
        nargs = 0,
        desc = 'A test command, prints "Hello from {command name}!"'
    }
)
