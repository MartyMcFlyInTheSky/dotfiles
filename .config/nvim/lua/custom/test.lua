--busted should be required before hooking debugger to avoid double-hooking
-- require("busted.runner")()
--
--
-- Undefined global describe
-- double tapping for continuation

if os.getenv("LOCAL_LUA_DEBUGGER_VSCODE") == "1" then
    require("lldebugger").start()
end

describe("a test with #mytag", function()
    -- tests to here
    -- vim.print("Hello")
    -- vim.print("Hello")
    -- vim.print("Hello")
    -- vim.print("Hello")
    -- vim.print("Hello")
    -- vim.print("Hello")
    -- vim.print("Hello")
    io.stderr:write("This is an error message\n")
    io.stdout:write("This is an error message\n")
end)

describe("second test", function()
    -- tests to here
    -- vim.print("Hello")
    -- vim.print("Hello")
    -- vim.print("Hello")
    -- vim.print("Hello")
    -- vim.print("Hello")
    -- vim.print("Hello")
    -- vim.print("Hello")
    io.stderr:write("This is an error message\n")
    io.stdout:write("This is an error message\n")
end)
