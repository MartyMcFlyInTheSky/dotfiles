-- Adapted freely from https://github.com/mfussenegger/nvim-dap/discussions/671#discussioncomment-4286738
--
local M = {}

-- Argument helpers (EmmyLua for lua-language-server)
---@class DapCargoArgs
---@field is_subcommand fun(arg: any): boolean
---@field subcommand fun(list: string[]|nil): string|nil
---@field contains fun(list: string[], value: string): boolean
---@field program_args_index fun(list: string[]): integer|nil
---@field insert_before_program_args fun(list: string[], value: string)
local args = {}

---@param arg any
---@return boolean
function args.is_subcommand(arg)
  return type(arg) == "string" and string.sub(arg, 1, 1) ~= "-"
end

---@param list string[]|nil
---@return string|nil
function args.subcommand(list)
  if not list then
    return nil
  end

  for _, arg in ipairs(list) do
    if args.is_subcommand(arg) then
      return arg
    end
  end

  return nil
end

---@param list string[]
---@param value string
---@return boolean
function args.contains(list, value)
  for _, arg in ipairs(list) do
    if arg == value then
      return true
    end
  end
  return false
end

---@param list string[]
---@return integer|nil
function args.program_args_index(list)
  for i = 1, #list do
    if list[i] == "--" then
      return i
    end
  end
  return nil
end

---@param list string[]
---@param value string
function args.insert_before_program_args(list, value)
  local insert_idx = args.program_args_index(list) or (#list + 1)
  table.insert(list, insert_idx, value)
end

-- ---------------------------------------------------------------------------

local function normalize_cargo_args(cargo_args)
  local message_format = "--message-format=json"
  local normalized = cargo_args or { message_format }

  if not args.contains(normalized, message_format) then
    args.insert_before_program_args(normalized, message_format)
  end

  if args.subcommand(normalized) == "test" then
    local no_run = "--no-run"
    if not args.contains(normalized, no_run) then
      args.insert_before_program_args(normalized, no_run)
    end
  end

  return normalized
end

local function expand_dap_config(config)
  local ok, dap = pcall(require, "dap")
  if not ok then
    return config
  end

  local expand = dap.listeners
    and dap.listeners.on_config
    and dap.listeners.on_config["dap.expand_variable"]

  if type(expand) == "function" then
    return expand(config)
  end

  return config
end

local function build_cargo_cmd(cargo_args)
  local cargo_cmd = { "cargo" }
  for _, value in ipairs(cargo_args) do
    table.insert(cargo_cmd, value)
  end
  return cargo_cmd
end

local function create_compiler_progress(config_name)
  local compiler_msg_buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_option(compiler_msg_buf, "buftype", "nofile")

  local window_width = math.max(#config_name + 1, 50)
  local window_height = 12
  local compiler_msg_window = vim.api.nvim_open_win(compiler_msg_buf, false, {
    relative = "editor",
    width = window_width,
    height = window_height,
    col = vim.api.nvim_get_option "columns" - window_width - 1,
    row = vim.api.nvim_get_option "lines" - window_height - 1,
    border = "rounded",
    style = "minimal",
  })

  vim.fn.appendbufline(compiler_msg_buf, "$", "Compiling: ")
  vim.fn.appendbufline(compiler_msg_buf, "$", config_name)
  vim.fn.appendbufline(compiler_msg_buf, "$", string.rep("=", window_width - 1))

  local function append(line)
    if vim.api.nvim_buf_is_valid(compiler_msg_buf) then
      vim.fn.appendbufline(compiler_msg_buf, "$", line)
      if vim.api.nvim_win_is_valid(compiler_msg_window) then
        vim.api.nvim_win_set_cursor(compiler_msg_window, { vim.api.nvim_buf_line_count(compiler_msg_buf), 1 })
      end
      vim.cmd "redraw"
    end
  end

  local function close()
    if vim.api.nvim_win_is_valid(compiler_msg_window) then
      vim.api.nvim_win_close(compiler_msg_window, { force = true })
    end

    if vim.api.nvim_buf_is_valid(compiler_msg_buf) then
      vim.api.nvim_buf_delete(compiler_msg_buf, { force = true })
    end
  end

  return {
    append = append,
    close = close,
  }
end

local function run_cargo_compile(final_config, progress)
  local compiler_metadata = {}
  local stderr_lines = {}
  local result = { exit_code = nil }

  local cargo_cmd = build_cargo_cmd(final_config.cargo.args)
  pcall(vim.fn.writefile, { table.concat(cargo_cmd, " ") }, "/tmp/dap-cargo-command.log")
  local cargo_job = vim.fn.jobstart(cargo_cmd, {
    clear_env = false,
    env = final_config.cargo.env,
    cwd = final_config.cwd,

    -- Cargo emits compiler artifacts as JSON on stdout; we parse it to find the real executable path.
    stdout_buffered = true,
    on_stdout = function(_, data)
      if type(data) ~= "table" then
        return
      end
      for _, line in ipairs(data) do
        if line ~= "" then
          table.insert(compiler_metadata, line)
        end
      end
    end,

    -- stderr is human compiler output; it can arrive in fragments, so we buffer and render it.
    on_stderr = function(_, data)
      local complete_line = ""
      for _, partial_line in ipairs(data) do
        if string.len(partial_line) ~= 0 then
          complete_line = complete_line .. partial_line
        end
      end

      if complete_line ~= "" then
        table.insert(stderr_lines, complete_line)
        progress.append(complete_line)
      end
    end,

    on_exit = function(_, code)
      result.exit_code = code
    end,
  })

  if cargo_job <= 0 then
    vim.notify(
      "Cargo failed to start for debug configuration:\n\n\t" .. final_config.name,
      vim.log.levels.ERROR
    )
  end

  return {
    job_id = cargo_job,
    metadata = compiler_metadata,
    exit_code = result.exit_code,
    result = result,
    stderr = stderr_lines,
    command = cargo_cmd,
  }
end

local function get_rustc_commit_hash_job()
  local rust_hash = ""
  local rust_hash_stdout = {}
  local rust_hash_job = vim.fn.jobstart({ "rustc", "--version", "--verbose" }, {
    clear_env = false,
    stdout_buffered = true,
    on_stdout = function(_, data) rust_hash_stdout = data end,
    on_exit = function()
      for _, line in pairs(rust_hash_stdout) do
        local start, finish = string.find(line, "commit-hash: ", 1, true)
        if start ~= nil then
          rust_hash = string.sub(line, finish + 1)
        end
      end
    end,
  })

  return {
    job_id = rust_hash_job,
    value = function()
      return rust_hash
    end,
  }
end

local function get_rustc_sysroot_job()
  local rust_source_path = ""
  local rust_source_job = vim.fn.jobstart({ "rustc", "--print", "sysroot" }, {
    clear_env = false,
    stdout_buffered = true,
    on_stdout = function(_, data) rust_source_path = data[1] end,
  })

  return {
    job_id = rust_source_job,
    value = function()
      return rust_source_path
    end,
  }
end

-- After extracting cargo's compiler metadata with the cargo inspector
-- parse it to find the binary to debug
local function parse_cargo_metadata(cargo_metadata)
  -- Iterate backwards through the metadata list since the binary
  -- we're interested will be near the end (usually second to last)
  for i = 1, #cargo_metadata do
    local json_table = cargo_metadata[#cargo_metadata + 1 - i]

    -- Some metadata lines may be blank, skip those
    if string.len(json_table) ~= 0 then
      -- Each matadata line is a JSON table,
      -- parse it into a data structure we can work with
      json_table = vim.fn.json_decode(json_table)

      -- Our binary will be the compiler artifact with an executable defined
      if json_table["reason"] == "compiler-artifact" then
        local executable = json_table["executable"]
        if executable ~= nil and executable ~= vim.NIL then
          return executable
        end
      end
    end
  end

  return nil
end

local function apply_compiled_executable(final_config, compiler_metadata, exit_code, stderr_lines, command)
  if exit_code == 0 then
    local executable_name = parse_cargo_metadata(compiler_metadata)
    if executable_name ~= nil then
      final_config.program = executable_name
    else
      pcall(vim.fn.writefile, compiler_metadata or {}, "/tmp/dap-cargo-metadata.log")
      if command ~= nil then
        pcall(vim.fn.writefile, { table.concat(command, " ") }, "/tmp/dap-cargo-command.log")
      end
      if stderr_lines ~= nil then
        pcall(vim.fn.writefile, stderr_lines, "/tmp/dap-cargo-stderr.log")
      end
      vim.notify(
        "Cargo could not find an executable for debug configuration:\n\n\t"
          .. final_config.name
          .. "\n\nMetadata written to /tmp/dap-cargo-metadata.log",
        vim.log.levels.ERROR
      )
    end
  else
    vim.notify("Cargo failed to compile debug configuration:\n\n\t" .. final_config.name, vim.log.levels.ERROR)
  end
end

local function apply_source_map(final_config, rust_hash, rust_source_path)
  -- Rust embeds stdlib paths as /rustc/<commit>/..., map them to the local toolchain sources.
  if rust_hash == "" or rust_source_path == "" then
    return
  end

  local hash_prefix = "/rustc/" .. rust_hash .. "/"
  local source_root = rust_source_path .. "/lib/rustlib/src/rust/"
  if final_config.sourceMap == nil then
    final_config.sourceMap = {}
  end
  final_config.sourceMap[hash_prefix] = source_root
end

-- Parse the `cargo` section of a DAP configuration and add any needed
-- information to the final configuration to be handed back to the adapter.
-- E.g.: When debugging a test, cargo generates a random executable name.
-- We need to ask cargo for the name and add it to the `program` config field
-- so LLDB can find it.
function M.resolve_cargo(config)
  local final_config = expand_dap_config(vim.deepcopy(config))

  -- Cargo emits JSON artifacts on stdout; we need those to resolve the real test executable.
  -- For tests, prevent immediate execution so the debugger can launch the binary.
  final_config.cargo.args = normalize_cargo_args(final_config.cargo.args)

  local compiler_progress = create_compiler_progress(final_config.name)
  local compiler_job = run_cargo_compile(final_config, compiler_progress)
  local rust_hash_job = get_rustc_commit_hash_job()
  local rust_source_job = get_rustc_sysroot_job()

  -- Block until compilation and rustc metadata are ready.
  vim.fn.jobwait { compiler_job.job_id, rust_hash_job.job_id, rust_source_job.job_id }

  compiler_progress.close()

  -- Enable visualization of built in Rust datatypes
  final_config.sourceLanguages = { "rust" }

  apply_compiled_executable(
    final_config,
    compiler_job.metadata,
    compiler_job.result.exit_code,
    compiler_job.stderr,
    compiler_job.command
  )
  apply_source_map(final_config, rust_hash_job.value(), rust_source_job.value())

  -- Cargo section is no longer needed
  final_config.cargo = nil

  return final_config
end

return M
