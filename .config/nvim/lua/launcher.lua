-- Requirements:
-- add ! to your shada (to persist global variables)
--
--TODO
-- be able to send ls -la as command or "ls" "-a" (with arguments => deconstruct in function)
-- Watch file changes and auto refresh dap configurations

local M = {}

local function telescope_modules()
    local ok_pick, pickers = pcall(require, "telescope.pickers")
    local ok_find, finders = pcall(require, "telescope.finders")
    local ok_conf, conf_mod = pcall(require, "telescope.config")
    local ok_actions, actions = pcall(require, "telescope.actions")
    local ok_state, action_state = pcall(require, "telescope.actions.state")
    local ok_prev, previewers = pcall(require, "telescope.previewers")

    if not (ok_pick and ok_find and ok_conf and ok_actions and ok_state and ok_prev) then
        vim.notify("Telescope is not available yet", vim.log.levels.WARN)
        return nil
    end

    return {
        pickers = pickers,
        finders = finders,
        conf = conf_mod.values,
        actions = actions,
        action_state = action_state,
        previewers = previewers,
    }
end

local tasks_local_file = vim.fs.abspath('.vscode/tasks.json')
local tasks_global_file = vim.fs.abspath('~/.vscode/tasks.json')

local launch_local_file = vim.fs.abspath('.vscode/launch.json')
local launch_global_file = vim.fs.abspath('~/.vscode/launch.json')

local metainfo_file = '.vscode/task_meta.json'

local TYPE = { shell = true, lua = true }
local function nonempty(s) return type(s) == "string" and s ~= "" end


--=============================================================================
-- Task reader & writer
--=============================================================================

---@class task
---@field type string
---@field label string
---@field command string

---@param task table Raw vscode.json task
local function validate_task(task)
    vim.validate('task', task, 'table')
    vim.validate('type', task.type, function(x) return TYPE[x] end, 'one of: shell|lua')
    vim.validate('label', task.label, nonempty, 'non-empty string')
    vim.validate('command', task.command, nonempty, 'non-empty string')
    return true
end


---@param filepath string Filepath for the tasks.json file to read
---@return task[] tasks
function M.read_tasks(filepath)
    -- Read file into a string
    local jsonstr = table.concat(vim.fn.readfile(filepath), "\n")

    -- Parse
    local parse = require("json5").parse
    local ok, data = pcall(parse, jsonstr)
    if not ok then
        vim.notify("JSON5 parse error: "..tostring(data), vim.log.levels.ERROR)
    end

    -- Split data into multiple records according to json
    local tasks = {}
    for _, task in ipairs(data.tasks) do
        -- Dismiss all tasks that don't correspond to a scheme that we can handle
        ok = pcall(validate_task, task)
        if ok then
            table.insert(tasks, { ["type"] = task.type, ["label"] = task.label, ["command"] = task.command })
        end
    end

    -- Return list of task
    return tasks
end


--=============================================================================
-- Selection reader & writer
--=============================================================================

---@class meta
---@field selection table | nil
---@field build_task table | nil

---@param meta meta Raw selection.json
local function validate_meta(meta)
    vim.validate('meta', meta, 'table')
    for key, task in pairs(meta) do
        vim.validate('key', key, 'string')
        vim.validate('task', task, validate_task)
    end
    return true
end

---@param filepath string Filepath for the selection.json file to read
---@return meta meta
function M.read_metainfo(filepath)
    -- Read file into a string
    local jsonstr = table.concat(vim.fn.readfile(filepath), "\n")

    -- Parse
    local parse = require("json5").parse
    local ok, meta = pcall(parse, jsonstr)
    if not ok then
        vim.notify("JSON5 parse error: "..tostring(meta), vim.log.levels.ERROR)
    end

    validate_meta(meta)

    return meta
end

---@param filepath string Path to metainfo file
---@param metainfo table Table to write for metainfo
function M.write_metainfo(filepath, metainfo)
    -- Serialize the file
    local json = vim.json.encode(metainfo)

    local file, err = io.open(filepath, 'w')
    if file == nil then
        vim.print("Could not open file " .. filepath .. " for writing:" .. err)
    end
    file:write(json)
    file:close()
end


---@param selection task
---@param how string
function M.write_selection(selection, how)
    -- Read metainfo
    local ok, meta = pcall(M.read_metainfo, metainfo_file)
    if not ok then
        meta = {}
    end
    meta[how] = selection
    M.write_metainfo(metainfo_file, meta)
end

--- Reads all tasks from global and local tasks.json
---@return task[] tasks List of tasks
---@return meta metainfo of the currently selected task (if any)
---@return integer i_sel Index of the currently selected task (if any)
---@return integer i_build_task Index of the currently selected task (if any)
function M.read_all_tasks()
    -- Read tasklist
    local ok, tasks = pcall(M.read_tasks, tasks_local_file)
    if not ok then
        tasks = {}
    end
    if tasks_local_file ~= tasks_global_file then
        local ok, tasks_global = pcall(M.read_tasks, tasks_global_file)
        if ok then
            vim.list_extend(tasks, tasks_global)
        end
    end

    -- Last selection that was accepted with <CR> will be highlighted
    local i_sel = 0 -- selection indexed, stays 0 if not found
    local ok, meta = pcall(M.read_metainfo, metainfo_file)
    if ok then
        for i, task in ipairs(tasks) do
            local tags = ""
            for key, selection in pairs(meta) do
                if vim.deep_equal(task, selection) then
                    tags = tags .. " <" .. key .. ">"
                    if key == 'enter' then
                        i_sel = i
                    end
                end
            end
            task.label = task.label .. tags
        end
    else
        meta = {}
    end

    -- vim.print("i_sel = " .. i_sel .. "i_build_task = " .. i_build_task)

    return tasks, meta, i_sel
end


--=============================================================================
-- Picker
--=============================================================================

function M.pick_task(opts)
    opts = opts or {}

    local telescope = telescope_modules()
    if not telescope then
        return
    end

    -- Read all tasks
    local tasks, metainfo, i_sel = M.read_all_tasks()
    -- vim.print("curr task is: ", curr_task)

    -- Create a picker using defined variables
    telescope.pickers.new(opts, {
        prompt_title = "Tasks",
        default_selection_index = i_sel,
        finder = telescope.finders.new_table {
            results = tasks,
            entry_maker = function(task)
                -- vim.print(vim.inspect(task))
                return {
                    value = task,
                    display = task.label,
                    ordinal = task.label,
                    preview_command = function(entry, bufnr)
                        local output = vim.split(vim.inspect(entry.value), '\n')
                        vim.api.nvim_buf_set_lines(bufnr, 0, -1, true, output)
                    end,
                }
            end,
        },
        sorter = telescope.conf.generic_sorter(opts),
        attach_mappings = function(prompt_bufnr, map)
            local function accept(how)
                return function()
                    local entry = telescope.action_state.get_selected_entry()
                    telescope.actions.close(prompt_bufnr)

                    local task = entry.value

                    -- Remember selection (without <key>)
                    -- for true do
                    --     task.label 
                    -- end
                    M.write_selection(task, how)

                    -- If task was selected using enter, execute it
                    if how == 'enter' then
                        M.launch_task(task)
                    end
                end
            end

            map('i', '<CR>', accept('enter'))
            map('i', '<F1>', accept('f1'))
            map('i', '<F2>', accept('f2'))
            map('i', '<F3>', accept('f3'))

            return true
        end,
        previewer = telescope.previewers.display_content.new(opts)
    }):find()
end


--=============================================================================
--  Launching
--=============================================================================

--- Async make
---@param task task Task object that is supposed to be executed
function M.launch_task(task)
    -- Assume tasks passed to us are in the correct (shell) format

    -- Build task
    local cmd = vim.fn.expandcmd(task.command)
    local split_cmd = vim.split(cmd, "%s")

    -- for i, arg in ipairs(split_cmd) do
    --     vim.print(i .. ": " .. arg)
    -- end

    -- vim.print(vim.inspect(split_cmd))

    -- vim.print("split task is " .. vim.inspect(cmd_list))

    -- Live lines into the current window (or create your own buffer/window)
    -- local buf = vim.api.nvim_create_buf(true, true)
    -- vim.api.nvim_set_current_buf(buf)

    -- local lines = {""}
    -- local winnr = vim.fn.win_getid()
    -- local bufnr = vim.api.nvim_win_get_buf(winnr)

    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_set_current_buf(buf)

    -- local makeprg = vim.api.nvim_buf_get_option(bufnr, "makeprg")
    -- if not makeprg then return end

    --- @param err string
    --- @param data string
    local function on_stdout(err, data)
        if not data then return end
        local ls = vim.split(data, "\n")
        vim.schedule(function()
            local last = vim.api.nvim_buf_line_count(buf)
            vim.api.nvim_buf_set_lines(buf, last-1, last, false, ls)
        end)
    end

    --- @param err string
    --- @param data string
    local function on_stderr(err, data)
        if not data then return end
        local ls = vim.split(data, "\n")
        vim.schedule(function()
            local last = vim.api.nvim_buf_line_count(buf)
            vim.api.nvim_buf_set_lines(buf, last-1, last, false, ls)
        end)
    end

    --- @param out vim.SystemCompleted
    local function on_exit(out)
        vim.schedule(function()
            if not vim.api.nvim_buf_is_valid(buf) then return end

            -- vim.print("current errorformat is: " .. vim.go.errorformat)

            -- vim.fn.setqflist({}, " ", {
            --     title = table.concat(cmd),
            --     lines = lines,
            --     -- efm = vim.go.errorformat
            --     -- efm = vim.api.nvim_buf_get_option(buf, "errorformat")
            --     efm = vim.go.errorformat
            -- })
            -- SAFE here:
            -- local bt = vim.bo[buf].buftype        -- same as nvim_buf_get_option(buf, 'buftype')
            -- -- ...do whatever you need; update windows, quickfix, notifications, etc.
            -- if res.code ~= 0 then
            --     vim.notify(("Task exited %d"):format(res.code), vim.log.levels.WARN)
            -- end
        end)
        -- vim.print("Task completed with exit code " .. out.code .. " completed")
        -- vim.fn.setqflist({}, " ", {
        --     title = cmd,
        --     lines = lines,
        --     efm = vim.api.nvim_buf_get_option(bufnr, "errorformat")
        -- })
        -- vim.api.nvim_command("doautocmd QuickFixCmdPost")

        -- Create quickfixlist
        -- vim.api.nvim_command("doautocmd QuickFixCmdPost") 
    end

    local obj = vim.system(
        split_cmd,
        {
            text = true,
            stdout = on_stdout,
            stderr = on_stderr,
        },
        on_exit
    )
    -- vim.print("Task with id " .. obj.pid .. " created!")
end

---@param how string Keystring to find the specific task in metainfo
function M.launch_task_key(how)
    -- Select and execute the build task
    local ok, meta = pcall(M.read_metainfo, metainfo_file)
    if ok then
        if meta[how] then
            M.launch_task(meta[how])
        end
    else
        vim.print("No task defined for " .. how .. "defined!")
    end
end


--=============================================================================
--  Editing
--=============================================================================

local function to_bufnr(x)
    if type(x) == "number" then return x end
    -- it's a path: create/load a buffer for it
    local b = vim.fn.bufadd(x)
    vim.fn.bufload(b)
    return b
end

function M.open_new_tab(bufA)
  local a = to_bufnr(bufA)

  -- new tab with one window
  vim.cmd("tabnew")
  local win1 = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(win1, a)
end

-- Open two buffers in a split in a new tab.
-- bufA / bufB can be a bufnr or a file path.
function M.split_open_new_tab(bufA, bufB)
  local a = to_bufnr(bufA)
  local b = to_bufnr(bufB)

  -- new tab with one window
  vim.cmd("tabnew")
  local win1 = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(win1, b)

  -- split and put bufB in the new window
  vim.cmd("topleft vsplit")
  local win2 = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(win2, a)
end



--=============================================================================
--  Commands & keybindings
--=============================================================================

local function in_dev_dir()
    -- All open() calls will be measured against getcwd() and not $PWD  
    local dev_dir = vim.fs.abspath('~/dev')
    local curr_dir = vim.fs.normalize(vim.fn.getenv("PWD")) -- explicitely don't resolve symlinks
    -- vim.print(curr_dir .. " = " .. dev_dir)
    return dev_dir == vim.fs.dirname(curr_dir)
end

vim.api.nvim_create_user_command('EditTasksJson', function()
    if not in_dev_dir() then
        M.open_new_tab(tasks_global_file)
    else
        M.split_open_new_tab(tasks_local_file, tasks_global_file)
    end
end, {})
vim.api.nvim_create_user_command('EditLaunchJson', function()
    if not in_dev_dir() then
        M.open_new_tab(launch_global_file)
    else
        M.split_open_new_tab(launch_local_file, launch_global_file)
    end
end, {})
vim.api.nvim_create_user_command('SelectTask', function() M.pick_task() end, {})

vim.keymap.set('n', '<C-g>', '<CMD>SelectTask<CR>', { noremap = true })
vim.keymap.set('n', '<F1>', function() M.launch_task_key('f1') end, { noremap = true })
vim.keymap.set('n', '<F2>', function() M.launch_task_key('f2') end, { noremap = true })
vim.keymap.set('n', '<F3>', function() M.launch_task_key('f3') end, { noremap = true })

vim.keymap.set('n', '<leader>et', '<CMD>EditTasksJson<CR>', { noremap = true })
vim.keymap.set('n', '<leader>el', '<CMD>EditLaunchJson<CR>', { noremap = true })

return M
