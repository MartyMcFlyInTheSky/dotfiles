--busted should be required before hooking debugger to avoid double-hooking

if os.getenv("LOCAL_LUA_DEBUGGER_VSCODE") == "1" then
  require("lldebugger").start()
end

vim.print("Hello World")

local function is_even(state, arguments)
  return function(value)
    return (value %2) == 0
  end
end

local function is_gt(state, arguments)
  local expected = arguments[1]
  return function(value)
    return value > expected
  end
end

assert:register("matcher", "even", is_even)
assert:register("matcher", "gt", is_gt)

describe("custom matchers", function()
  it("match even", function()
    local s = spy.new(function() end)

    s(2)

    assert.spy(s).was_called_with(match.is_even())
  end)

  it("match greater than", function()
    local s = spy.new(function() end)

    s(10)

    assert.spy(s).was_called_with(match.is_gt(5))
  end)
end)
