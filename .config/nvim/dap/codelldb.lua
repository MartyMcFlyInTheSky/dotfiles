local ok, settings = pcall(require, 'mason.settings')
if not ok then
  local ok_lazy, lazy = pcall(require, 'lazy')
  if ok_lazy then
    pcall(lazy.load, { plugins = { 'mason.nvim' } })
    ok, settings = pcall(require, 'mason.settings')
  end
end
if not ok then
  vim.notify('mason settings not available; install mason.nvim', vim.log.levels.ERROR)
  return nil
end

local mason_root = settings.current.install_root_dir
local extension_path = mason_root .. '/packages/codelldb/extension/'
local codelldb_path = extension_path .. 'adapter/codelldb'
local liblldb_path = extension_path .. 'lldb/lib/liblldb.so'

if vim.uv.fs_stat(codelldb_path) == nil or vim.uv.fs_stat(liblldb_path) == nil then
  vim.notify('codelldb not installed via Mason. Run :MasonInstall codelldb', vim.log.levels.ERROR)
  return nil
end

return {
  type = 'server',
  port = '${port}',
  host = '127.0.0.1',
  executable = {
    command = codelldb_path,
    args = { '--liblldb', liblldb_path, '--port', '${port}' },
  },
  enrich_config = function(config, on_config)
    if config.cargo ~= nil then
      local resolver = require('custom.dap-resolve-cargo')
      on_config(resolver.resolve_cargo(config))
      return
    end

    on_config(config)
  end,
}
