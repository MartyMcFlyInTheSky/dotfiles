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
local adapter_path = mason_root .. '/packages/cpptools/extension/debugAdapters/bin/OpenDebugAD7'

if vim.uv.fs_stat(adapter_path) == nil then
  vim.notify('cpptools not installed via Mason. Run :MasonInstall cpptools', vim.log.levels.ERROR)
  return nil
end

return {
  id = 'cppdbg',
  type = 'executable',
  command = adapter_path,
  options = {
    detached = false,
  },
}
