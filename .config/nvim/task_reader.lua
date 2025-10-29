local M = {}

--- Dispatches a task to nvim jobcontrol (async)
--- @param task string Shellstring
local function launch_task(task)
    vim.print("Launching task " .. task)

    local output_file = ".vscode/cmd_out.txt"

    -- launch job in shell
    -- write output to file
    -- file can be easily accessed by 
    
    local lines = {}

    vim.fn.jobstart({ vim.o.shell, vim.o.shellcmdflag, task }, {
        stdout_buffered = true,
        on_stdout = function(_, data)
            vim.list_extend(lines, data)
        end,
        on_stderr = function(_, data)
            vim.list_extend(lines, data)
        end,
        on_exit = function()
            -- data are the lines printed by the task
            vim.fn.writefile(lines, output_file)
            vim.print("finished!")
            -- vim.schedule(function()
            -- if not vim.api.nvim_buf_is_valid(buf) then return end

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
        end
    })

--     -- Unprotected check, error out in case it fails
--     validate_task(task)
--
--     -- Expand and disect command
--     -- vim.fin
--
--     -- Build task
--     local cmd = { vim.fn.expandcmd(task.command) }
--     local cmd = vim.list_extend(cmd, task.args or {})
--
--     vim.print(vim.inspect(cmd))
--
--     -- vim.print("split task is " .. vim.inspect(cmd_list))
--
--     -- Live lines into the current window (or create your own buffer/window)
--     -- local buf = vim.api.nvim_create_buf(true, true)
--     -- vim.api.nvim_set_current_buf(buf)
--
--     local lines = {""}
--     local winnr = vim.fn.win_getid()
--     -- local bufnr = vim.api.nvim_win_get_buf(winnr)
--
--     local buf = vim.api.nvim_create_buf(false, true)
--     vim.api.nvim_set_current_buf(buf)
--
--     -- local makeprg = vim.api.nvim_buf_get_option(bufnr, "makeprg")
--     -- if not makeprg then return end
--
--     --- @param err string
--     --- @param data string
--     local function on_stdout(err, data)
--         if not data then return end
--         local ls = vim.split(data, "\n")
--         vim.schedule(function()
--             local last = vim.api.nvim_buf_line_count(buf)
--             vim.api.nvim_buf_set_lines(buf, last-1, last, false, ls)
--         end)
--     end
--
--     --- @param err string
--     --- @param data string
--     local function on_stderr(err, data)
--         if not data then return end
--         local ls = vim.split(data, "\n")
--         vim.list_extend(lines, ls) 
--         vim.schedule(function()
--             local last = vim.api.nvim_buf_line_count(buf)
--             vim.api.nvim_buf_set_lines(buf, last-1, last, false, ls)
--         end)
--     end
--
--     --- @param out vim.SystemCompleted
--     local function on_exit(out)
--         vim.schedule(function()
--             if not vim.api.nvim_buf_is_valid(buf) then return end
--
--             vim.print("current errorformat is: " .. vim.go.errorformat)
--
--             vim.fn.setqflist({}, " ", {
--                 title = table.concat(cmd),
--                 lines = lines,
--                 -- efm = vim.go.errorformat
--                 -- efm = vim.api.nvim_buf_get_option(buf, "errorformat")
--                 efm = vim.go.errorformat
--             })
--             -- SAFE here:
--             -- local bt = vim.bo[buf].buftype        -- same as nvim_buf_get_option(buf, 'buftype')
--             -- -- ...do whatever you need; update windows, quickfix, notifications, etc.
--             -- if res.code ~= 0 then
--             --     vim.notify(("Task exited %d"):format(res.code), vim.log.levels.WARN)
--             -- end
--         end)
--         -- vim.print("Task completed with exit code " .. out.code .. " completed")
--         -- vim.fn.setqflist({}, " ", {
--         --     title = cmd,
--         --     lines = lines,
--         --     efm = vim.api.nvim_buf_get_option(bufnr, "errorformat")
--         -- })
--         -- vim.api.nvim_command("doautocmd QuickFixCmdPost")
--
--         -- Create quickfixlist
--         -- vim.api.nvim_command("doautocmd QuickFixCmdPost") 
--     end
--
--     local obj = vim.system(
--         cmd,
--         {
--             text = true,
--             stdout = on_stdout,
--             stderr = on_stderr,
--         },
--         on_exit
--     )
--
--     vim.print("Task with id " .. obj.pid .. " created!")
end


function M.read_tasks_json()
    local parse = require("json5").parse

    local task_file = ".vscode/tasks.json"
    local select_file = ".vscode/selection.json"

    -- 1) Read tasks.json
    local f, err = io.open(task_file, "rb")
    if not f then
        -- That's ok
        return {}
    end
    local tasks_input = f:read("*a")
    f:close()

    local ok, taskcfg = pcall(parse, tasks_input)
    if not ok then
        vim.notify("JSON5 parse error: "..tostring(taskcfg), vim.log.levels.ERROR)
        return {}
    end

    -- 2) Read task_selection.json
    f, err = io.open(select_file, "rb")
    if f then
        local selection_input = f:read("*a")
        f:close()
        local ok, item = pcall(vim.json.decode, selection_input)
        if not ok then
            vim.notify("json.decode error: "..tostring(taskcfg), vim.log.levels.ERROR)
            return {}
        end
        taskcfg.selected = item.selected
    else
        taskcfg.selected = "" -- Empty string
    end

    return taskcfg
end

--- Write task back into temporary file
---@param task string Shell line to be executed
function M.prepare_launch_task(task)
    -- For external facilities that want to use their own launcher
    -- Still select last launched entry
    local select_file = ".vscode/selection.json"

    -- If file exists read the contents
    local item = {}
    local f, err = io.open(select_file, "r+b")
    if f then
        local selection_input = f:read("*a")
        f:close()
        local ok, item = pcall(vim.json.decode, selection_input)
        if not ok then
            vim.notify("json.decode error: "..tostring(item), vim.log.levels.ERROR)
        end
    end

    -- Change / add property
    item.selected = task
    local ok, out = pcall(vim.json.encode, item)
    if not ok then
        vim.notify("json.encode error: "..tostring(item), vim.log.levels.ERROR)
    end

    -- Write to file
    local f, err = io.open(select_file, "w+b")
    if not f then
        vim.print("failed to open file " .. tostring(f) .. " for writing due to error: " .. err)
        return
    end
    f:write(out)
    f:close()
end


-- function M.launch_task()
--     prepare_launch_task() 
-- end
--

local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local conf = require("telescope.config").values
local actions      = require'telescope.actions'
local action_state = require'telescope.actions.state'
local previewers   = require'telescope.previewers'

function M.show_proj_tasks()
    vim.print("Hello")

    local taskcfg = M.read_tasks_json()

    -- Arrange
    local tasks = {}
    local selected = taskcfg.selected
    local index = 1
    for i, task in ipairs(taskcfg.tasks) do
        table.insert(tasks, task.command)
        vim.print("index = " .. i)
        if task == selected then
            index = i
        end
    end

    local opts={}
    pickers.new(opts, {
        promt_title = "Project tasks",
        finder = finders.new_table({
            results = taskcfg.tasks,
            entry_maker = function(task)
                return {
                    value = task.command,
                    ordinal = task.command,
                    display = task.command,
                }
            end,
        }),
        sorter = conf.generic_sorter(opts),
        attach_mappings = function(prompt_bufnr)
            actions.select_default:replace(function()
                local selection = action_state.get_selected_entry()
                actions.close(prompt_bufnr)

                local task = selection.value

                -- Write back to
                vim.print("Entry " .. vim.inspect(selection) .. " picked!")
                M.prepare_launch_task(task)
                
                -- Execute task
                launch_task(task)
            end)

            return true
        end,
    }):find()
end


-- Register command
vim.api.nvim_create_user_command("ShowProjTasks", M.show_proj_tasks, { desc="Show shell tasks in .vscode/tasks.json", force=true })

return M
