local M = {}

local function load_adapter(path)
  local ok, adapter = pcall(dofile, path)
  if not ok then
    vim.notify('dap loader: failed to load ' .. path .. ': ' .. adapter, vim.log.levels.ERROR)
    return nil
  end
 return adapter
end

function M.setup(dap)
  local config_dir = vim.fn.stdpath('config')
  local dap_dir = vim.fs.joinpath(config_dir, 'dap')
  if not vim.uv.fs_stat(dap_dir) then
    return
  end
  for name, type in vim.fs.dir(dap_dir) do
    if type == 'file' and name:sub(-4) == '.lua' then
      local path = vim.fs.joinpath(dap_dir, name)
      local adapter = load_adapter(path)
      if adapter ~= nil then
        local key = name:gsub('%.lua$', '')
        dap.adapters[key] = adapter
      end
    end
  end
end

return M
