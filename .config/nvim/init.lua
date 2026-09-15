-- TODO
-- - feat: display red statusline when file being edited is outside of workspace directory

-- TODO Telescope:
-- - fix: When opening gitfile overview from non-git folder it errors
-- - feat: make fallback for when no git source tree found

-- TODO neovim:
-- - fix: race condition in snippets.lua

-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)

-- Rotate LSP log on startup (keep 2 backups)
do
  local log_path = vim.lsp.log.get_filename()
  if vim.uv.fs_stat(log_path) then
    os.remove(log_path .. ".2")
    os.rename(log_path .. ".1", log_path .. ".2")
    os.rename(log_path, log_path .. ".1")
    vim.fn.writefile({}, log_path)
  end
end

-- Load old Vimscript config
-- local home = vim.uv.os_homedir()
-- local xdg_config_home = vim.env.XDG_CONFIG_HOME or (home .. '/.config')

-- Add vims packpath to our own so we can source same colorscheme
vim.opt.packpath:append(vim.fn.stdpath('config') .. "/../vim")

local vimrc = vim.fn.stdpath('config') .. "/../vim/vimrc"
if vim.fn.filereadable(vimrc) == 1 then
    local ok, err = pcall(vim.cmd, "source " .. vimrc)
    if not ok then
        vim.notify("Failed to source vimrc: " .. err, vim.log.levels.ERROR)
    end
end

vim.go.loadplugins = true
require("config.settings")
require("config.lazy")
require("config.keybindings")
require("launcher")
require("globals")
-- require("config.cmds")

-- Enable experimental ui2 (optional, can disable anytime)
require('vim._core.ui2').enable()
vim.o.cmdheight = 0  -- reclaim one line with ui2

-- Document color with color swatches (virtual text)
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('document_color', {}),
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if client:supports_method('textDocument/documentColor') then
      vim.lsp.document_color.enable(true, { bufnr = ev.buf })
    end
  end,
})

-- Base config (merged with lsp/<config>.lua files)
vim.lsp.config('*', {
  capabilities = {
    textDocument = {
      semanticTokens = {
        multilineTokenSupport = true,
      }
    }
  },
  root_markers = { '.git' },
})
vim.lsp.enable({
    'clangd',
    'lua_ls',
    'pyright',
    'bashls',
    'gopls',
    -- 'rust-analyzer', -- managed by rustaceanvim
})

-- Add dylib to package cpath (https://github.com/Joakker/lua-json5)
package.cpath = package.cpath .. ';?.dylib'

-- Prevent LSP from overwriting treesitter color settings (https://github.com/NvChad/NvChad/issues/1907)
vim.hl.priorities.semantic_tokens = 95 -- Or any number lower than 100, treesitter's priority level

--=============================================================================
--  Configure diagnostics-api
--=============================================================================

vim.diagnostic.config {
  virtual_text = {
    prefix = '●',
    -- Add a custom format function to show error codes
    format = function(diagnostic)
      local code = diagnostic.code and string.format('[%s]', diagnostic.code) or ''
      return string.format('%s %s', code, diagnostic.message)
    end,
  },
  underline = false,
  update_in_insert = true,
  float = {
    source = true, -- Or "if_many"
  },
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = ' ',
      [vim.diagnostic.severity.WARN] = ' ',
      [vim.diagnostic.severity.INFO] = ' ',
      [vim.diagnostic.severity.HINT] = '󰌵 ',
    },
  },
  -- Make diagnostic background transparent
  on_ready = function()
    vim.cmd 'highlight DiagnosticVirtualText guibg=NONE'
  end,
}

vim.keymap.set("n", "gl", vim.diagnostic.open_float, { noremap = true, silent = true })

-- Toggle LSP diagnostics: virtual text <-> virtual lines
vim.keymap.set("n", "grl", function()
  local cfg = vim.diagnostic.config()
  local vt = cfg.virtual_text
  local vl = cfg.virtual_lines
  local vt_on = (vt == nil) or (vt == true) or (type(vt) == "table")
  local vl_on = (vl == true) or (type(vl) == "table")
  if vl_on then
    vim.diagnostic.config({ virtual_text = true, virtual_lines = false })
  elseif vt_on then
    vim.diagnostic.config({ virtual_text = false, virtual_lines = true })
  else
    vim.diagnostic.config({ virtual_text = true, virtual_lines = false })
  end
end, { desc = "Toggle diagnostics virtual text/lines" })

--=============================================================================
--  Additional language
--=============================================================================

vim.treesitter.language.register('json5', 'json')   -- use json5 for ft=json
vim.treesitter.language.register('json5', 'jsonc')  -- optional: also for jsonc


--=============================================================================
--  Autocommands
--=============================================================================
--
-- (mostly adapted from https://www.youtube.com/watch?v=v36vLiFVOXY)

-- Visually highlight
vim.api.nvim_create_autocmd('TextYankPost', {
    group = vim.api.nvim_create_augroup("highlight_yank", { clear = true }),
    pattern = "*",
    desc = "Highlight selection on yank",
    callback = function()
        vim.highlight.on_yank({ timeout = 200, visual = true })
    end,
})

-- Resize split with window
-- TODO:
-- - fix: doesn't resize when using tabs
vim.api.nvim_create_autocmd('VimResized', {
    command = "wincmd =",
})

-- Open help in vertical split
vim.api.nvim_create_autocmd('FileType', {
    pattern = "help",
    command = "wincmd L",
})

-- LSP symbol highlighting
vim.api.nvim_create_autocmd("CursorMoved", {
	group = vim.api.nvim_create_augroup("LspReferenceHighlight", { clear = true }),
	desc = "Highlight references under cursor",
	callback = function()
		-- Only run if the cursor is not in insert mode
		if vim.fn.mode() ~= "i" then
			local clients = vim.lsp.get_clients({ bufnr = 0 })
			local supports_highlight = false
			for _, client in ipairs(clients) do
				if client.server_capabilities.documentHighlightProvider then
					supports_highlight = true
					break -- Found a supporting client, no need to check others
				end
			end

			-- 3. Proceed only if an LSP is active AND supports the feature
			if supports_highlight then
				vim.lsp.buf.clear_references()
				vim.lsp.buf.document_highlight()
			end
		end
	end,
})

-- Formatprog jq for json files
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "json", "jsonc" }, -- drop "jsonc" if you don't use it
  callback = function()
    -- Pretty-print with jq (the '.' filter prints as-is, formatted)
    vim.opt_local.formatprg = "jq ."
  end,
})


-- LSP
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("UserLspKeymaps", { clear = true }),
  callback = function(ev)
    local bufnr = ev.buf
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if not client then return end

    local function map(lhs, rhs, desc)
      vim.keymap.set("n", lhs, rhs, { buffer = bufnr, silent = true, noremap = true, desc = desc })
    end

    -- go to definition
    if client:supports_method("textDocument/definition") then
      map("gd", vim.lsp.buf.definition, "LSP: Go to definition")
    end

    -- go to declaration
    if client:supports_method("textDocument/declaration") then
      map("gD", vim.lsp.buf.declaration, "LSP: Go to declaration")
    end

    -- formatting (optional)
    -- if client:supports_method("textDocument/formatting") then
    --   map("gf", function()
    --     vim.lsp.buf.format({ bufnr = bufnr, timeout_ms = 1000 })
    --   end, "LSP: Format")
    -- end
  end,
})


vim.api.nvim_create_user_command("RunRunFake", function()
    local cols = vim.o.columns
    local lines = vim.o.lines
    local width = math.max(40, math.floor(cols * 0.8))
    local height = math.max(8, math.floor(lines * 0.6))
    if width > cols then width = math.max(1, cols) end
    if height > lines then height = math.max(1, lines) end
    local row = math.max(0, math.floor((lines - height) / 2))
    local col = math.max(0, math.floor((cols - width) / 2))
    local prompt_buf = vim.api.nvim_create_buf(false, true)
    -- replicate current config
    vim.api.nvim_open_win(prompt_buf, true, {
      relative = "editor",
      row = row,
      col = col,
      width = width,
      height = 1,
      style = "minimal",
      border = "rounded",
    })
end, {})

--=============================================================================
--  Three-Way Merge Conflict Resolution
--=============================================================================

vim.api.nvim_create_user_command("MergeConflict", function()
  local bufnr = vim.api.nvim_get_current_buf()
  local filepath = vim.api.nvim_buf_get_name(bufnr)

  if filepath == "" then
    vim.notify("No file associated with current buffer", vim.log.levels.ERROR)
    return
  end

  -- Get relative path for git (in case we're in a subdirectory)
  local git_file = filepath
  local git_root = vim.fn.system("git rev-parse --show-toplevel 2>/dev/null"):gsub("\n", "")
  if git_root ~= "" and filepath:sub(1, #git_root) == git_root then
    git_file = filepath:sub(#git_root + 2) -- +2 to skip the leading /
  end

  -- Fetch HEAD version (:2 = ours)
  local head_cmd = "git show :2:" .. vim.fn.shellescape(git_file) .. " 2>/dev/null"
  local head_content = vim.fn.system(head_cmd)
  if vim.v.shell_error ~= 0 then
    vim.notify("Failed to get HEAD version from git index", vim.log.levels.ERROR)
    return
  end

  -- Fetch incoming version (:3 = theirs)
  local incoming_cmd = "git show :3:" .. vim.fn.shellescape(git_file) .. " 2>/dev/null"
  local incoming_content = vim.fn.system(incoming_cmd)
  if vim.v.shell_error ~= 0 then
    vim.notify("Failed to get incoming version from git index", vim.log.levels.ERROR)
    return
  end

  -- Save current cursor position
  local cursor_pos = vim.api.nvim_win_get_cursor(0)

  -- Create new buffers for HEAD and incoming
  local head_buf = vim.api.nvim_create_buf(false, true)
  local incoming_buf = vim.api.nvim_create_buf(false, true)

  -- Populate buffers with content
  local head_lines = vim.split(head_content, "\n")
  local incoming_lines = vim.split(incoming_content, "\n")

  vim.api.nvim_buf_set_lines(head_buf, 0, -1, false, head_lines)
  vim.api.nvim_buf_set_lines(incoming_buf, 0, -1, false, incoming_lines)

  -- Mark buffers as non-modifiable (read-only)
  vim.api.nvim_set_option_value("modifiable", false, { buf = head_buf })
  vim.api.nvim_set_option_value("modifiable", false, { buf = incoming_buf })

  -- Name buffers descriptively (unique per invocation via bufnr suffix, so
  -- repeated :MergeConflict calls never collide) so statuslines/winbars that
  -- read the buffer name show something other than the "[Scratch]" fallback.
  vim.api.nvim_buf_set_name(head_buf, string.format("HEAD (ours) [%d]", head_buf))
  vim.api.nvim_buf_set_name(incoming_buf, string.format("INCOMING (theirs) [%d]", incoming_buf))

  -- Split layout: HEAD (left) | Current (middle) | Incoming (right)
  -- First, split vertically to create left pane
  vim.cmd("vsplit")
  vim.api.nvim_set_current_buf(head_buf)
  vim.cmd("setlocal buftype=nofile")
  vim.cmd("setlocal bufhidden=wipe")
  vim.cmd("setlocal nobuflisted")
  vim.cmd("setlocal filetype=merge")
  vim.wo.winbar = "HEAD (ours)"
  vim.cmd("diffthis")
  -- Render changed hunks the way CodeDiff does: this is the "old" side, so
  -- render DiffChange/DiffText as delete-colored (red) rather than native
  -- vim's single gray DiffChange/DiffText.
  vim.wo.winhighlight = "DiffChange:DiffDelete,DiffText:DiffTextDelete"

  -- Move to the right split and split again for incoming
  vim.cmd("wincmd l")
  vim.cmd("vsplit")
  vim.cmd("wincmd l")
  vim.api.nvim_set_current_buf(incoming_buf)
  vim.cmd("setlocal buftype=nofile")
  vim.cmd("setlocal bufhidden=wipe")
  vim.cmd("setlocal nobuflisted")
  vim.cmd("setlocal filetype=merge")
  vim.wo.winbar = "INCOMING (theirs)"
  vim.cmd("diffthis")
  -- This is the "new" side, so render as insert-colored (green).
  vim.wo.winhighlight = "DiffChange:DiffAdd,DiffText:DiffTextAdd"

  -- Back to middle pane (original buffer)
  vim.cmd("wincmd h")
  vim.api.nvim_win_set_cursor(0, cursor_pos)
  local middle_win = vim.api.nvim_get_current_win()
  vim.cmd("diffthis")
  -- Middle pane is ambiguous relative to both sides, so it keeps native
  -- gray DiffChange/DiffText (no winhighlight override here).

  -- Ensure middle window exits diff mode once either scratch pane is wiped,
  -- so it doesn't get stuck in diff mode after the user closes one side.
  vim.api.nvim_create_autocmd("BufWipeout", {
    buffer = head_buf,
    once = true,
    callback = function()
      if vim.api.nvim_win_is_valid(middle_win) then
        vim.api.nvim_win_call(middle_win, function() vim.cmd("diffoff") end)
      end
    end,
  })
  vim.api.nvim_create_autocmd("BufWipeout", {
    buffer = incoming_buf,
    once = true,
    callback = function()
      if vim.api.nvim_win_is_valid(middle_win) then
        vim.api.nvim_win_call(middle_win, function() vim.cmd("diffoff") end)
      end
    end,
  })

  -- Add window labels via statusline hint
  vim.notify("Three-way merge opened: HEAD (left) | Working (middle) | Incoming (right)", vim.log.levels.INFO)
end, {
  desc = "Open three-way merge view for conflict resolution"
})
