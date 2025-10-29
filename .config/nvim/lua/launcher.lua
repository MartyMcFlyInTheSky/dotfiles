-- Requirements:
-- add ! to your shada (to persist global variables)
--
-- TODO
-- be able to send ls -la as command or "ls" "-a" (with arguments => deconstruct in function)

local M = {}

local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local conf = require("telescope.config").values
local actions      = require'telescope.actions'
local action_state = require'telescope.actions.state'
local previewers   = require'telescope.previewers'

local tasks_local_file = '.vscode/tasks.json'
local tasks_global_file = vim.fn.expand('~/.vscode/tasks.json')
local selection_file = '.vscode/selection.json'


--=============================================================================
-- Selection reader & writer
--=============================================================================

---@class selection
---@field type string
---@field label string
---@field command string

---@param rawsel table Raw selection.json
local function validate_selection(rawsel)
  vim.validate({
    task    = { rawsel, 'table' },
    type    = { rawsel.type, function(x) return TYPE[x] end, 'one of: shell|lua' },
    label   = { rawsel.label, nonempty, 'non-empty string' },
    command = { rawsel.command, nonempty, 'non-empty string' },
  })
  return true
end

---@param filepath string Filepath for the selection.json file to read
---@return selection string
function M.read_selection(filepath)
    -- Read file into a string
    local jsonstr = table.concat(vim.fn.readfile(filepath), "\n")

    -- Parse
    local parse = require("json5").parse
    local ok, selection = pcall(parse, jsonstr)
    if not ok then
        vim.notify("JSON5 parse error: "..tostring(selection), vim.log.levels.ERROR)
    end

    return selection
end

function M.write_selection(filepath, selection)
    -- Serialize the file
    local json = vim.json.encode(selection)

    local file, err = io.open(filepath, 'w')
    if file == nil then
        vim.print("Could not open file " .. filepath .. " for writing:" .. err)
    end
    file:write(json)
    file:close()
end


--=============================================================================
-- Task reader & writer
--=============================================================================

---@class task
---@field type string
---@field label string
---@field command string

local TYPE = { shell = true, lua = true }
local function nonempty(s) return type(s) == "string" and s ~= "" end

---@param rawtask table Raw vscode.json task
local function validate_task(rawtask)
  vim.validate({
    task    = { rawtask, 'table' },
    type    = { rawtask.type, function(x) return TYPE[x] end, 'one of: shell|lua' },
    label   = { rawtask.label, nonempty, 'non-empty string' },
    command = { rawtask.command, nonempty, 'non-empty string' },
  })
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

--- Reads all tasks from global and local tasks.json
---@return task[] tasks List of tasks
---@return integer i_sel Index of the currently selected task (if any)
function M.read_all_tasks()
    -- Read tasklist
    local ok, tasks = pcall(M.read_tasks, tasks_local_file)
    if not ok then
        tasks = {}
    end
    local ok, tasks_global = pcall(M.read_tasks, tasks_global_file)
    if ok then
        vim.list_extend(tasks, tasks_global)
    end

    -- Read selection information 
    local i_sel = 0 -- selection indexed, stays 0 if not found
    local ok, selection = pcall(M.read_selection, selection_file)
    if ok then
        for i, task in ipairs(tasks) do
            if vim.deep_equal(task, selection) then
                i_sel = i
            end
        end
    end

    return tasks, i_sel
end

--=============================================================================
-- Picker
--=============================================================================

function M.pick_task(opts)
    opts = opts or {}

    -- Read all tasks
    local tasks, i_sel = M.read_all_tasks()
    -- vim.print("curr task is: ", curr_task)

    -- Create a picker using defined variables
    pickers.new(opts, {
        prompt_title = "Tasks",
        default_selection_index = i_sel,
        finder = finders.new_table {
            results = tasks,
            entry_maker = function(task)
                -- vim.print(vim.inspect(task))
                return {
                    value = task,
                    display = task.type .. ': ' .. task.label,
                    ordinal = task.type .. ': ' .. task.label,
                    preview_command = function(entry, bufnr)
                        local output = vim.split(vim.inspect(entry.value), '\n')
                        vim.api.nvim_buf_set_lines(bufnr, 0, -1, true, output)
                    end,
                }
            end,
        },
        sorter = conf.generic_sorter(opts),
        attach_mappings = function(prompt_bufnr)
            actions.select_default:replace(function()
                local entry = action_state.get_selected_entry()
                actions.close(prompt_bufnr)

                local selection = entry.value
                M.write_selection(selection_file, selection)
                M.launch_task(selection)
            end)

            return true
        end,
        previewer = previewers.display_content.new(opts)
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

    vim.print(vim.inspect(split_cmd))

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


vim.api.nvim_create_user_command('SelectLaunchTask', function() M.pick_task() end, {})

-- Launcher
-- vim.keymap.set('n', '<F6>', '<CMD>LaunchCurrTask<CR>', { noremap = true })
vim.keymap.set('n', '<C-t>', '<CMD>SelectLaunchTask<CR>', { noremap = true })

-- vim.api.nvim_create_user_command('LaunchCurrTask', function(opts)
--     -- Execute task
--     if curr_task ~= nil and next(curr_task) ~= nil then
--         LaunchTask(curr_task)
--     else
--         vim.notify("No current task defined.", vim.log.levels.INFO)
--     end
-- end , {})


-- (Optional) handy commands for debugging
-- vim.api.nvim_create_user_command("MyPluginSave", save_state, {})
-- vim.api.nvim_create_user_command("MyPluginLoad", load_state, {})

--=============================================================================
--  Editing
--=============================================================================

-- --- @param path string Path to the file to edit
-- function M.edit_tasks(path.) 
--    vim.fn.edit() 
-- end

vim.api.nvim_create_user_command('EditGlobalTasksJson', function() vim.cmd.edit(tasks_global_file) end, {})
vim.api.nvim_create_user_command('EditLocalTasksJson', function() vim.cmd.edit(tasks_local_file) end, {})

vim.keymap.set('n', '<leader>et', '<CMD>EditGlobalTasksJson<CR>', { noremap = true })

return M

