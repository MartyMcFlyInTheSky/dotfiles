
-- vim.print("Hello from other")

return {
  type = "executable",
  command = "gdb",
  args = { "--interpreter=dap", "--eval-command", "set print pretty on" },
  filetypes = { "otherft" }
}
