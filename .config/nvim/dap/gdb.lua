-- local dap = require("dap")
-- dap.adapters.gdb = {
--

return {
    type = "executable",
    command = "gdb",
    args = { "--interpreter=dap", "--eval-command", "set print pretty on" },
    filetypes = { 'c', 'cpp', 'objc', 'objcpp', 'cuda' },
}
