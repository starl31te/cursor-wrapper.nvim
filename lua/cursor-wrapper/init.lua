local M = {}

local C = require("cursor-wrapper.config")

function M.setup(opts)
    opts = opts or {}
    for key, value in pairs(opts) do
        config[key] = value
    end
end

local context_term_buf_id = nil
local no_context_term_buf_id = nil

function M.smart_escape()
    local current_buf = vim.api.nvim_get_current_buf()
    if current_buf == context_term_buf_id or current_buf == no_context_term_buf_id then
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<C-\\><C-n>', true, false, true), 'n', false)
    end
end

function M.get_visual_selection()
    local start_pos = vim.api.nvim_buf_get_mark(0, '<')
    local end_pos = vim.api.nvim_buf_get_mark(0, '>')
    if start_pos[1] == 0 or end_pos[1] == 0 then
        return ''
    end
    local lines = vim.api.nvim_buf_get_text(
        0, start_pos[1] - 1, start_pos[2], end_pos[1] - 1, end_pos[2], {}
    )
    return table.concat(lines, '\n')
end

local function create_terminal_split(command, buffer_name)
    if config.split_position == 'top' then
        vim.cmd('new')
    elseif config.split_position == 'bottom' then
        vim.cmd('rightbelow new')
    elseif config.split_position == 'left' then
        vim.cmd('vnew')
    else
        vim.cmd('rightbelow vnew')
    end

    if config.split_position == 'left' or config.split_position == 'right' then
        local width = math.floor(vim.o.columns * config.split_size)
        vim.cmd('vertical resize ' .. width)
    else
        local height = math.floor(vim.o.lines * config.split_size)
        vim.cmd('resize ' .. height)
    end

    vim.fn.termopen(command)

    local new_buf_id = vim.api.nvim_get_current_buf()
    vim.api.nvim_buf_set_name(new_buf_id, buffer_name)
    vim.cmd('startinsert')
    return new_buf_id
end

function M.open_cursor_terminal()
    if context_term_buf_id and vim.api.nvim_buf_is_valid(context_term_buf_id) then
        local win_id = vim.fn.bufwinid(context_term_buf_id)
        if win_id ~= -1 then
            vim.api.nvim_set_current_win(win_id)
            vim.cmd('startinsert')
            return
        else
            vim.api.nvim_buf_delete(context_term_buf_id, { force = true })
            context_term_buf_id = nil
        end
    end
    if no_context_term_buf_id and vim.api.nvim_buf_is_valid(no_context_term_buf_id) then
        vim.api.nvim_buf_delete(no_context_term_buf_id, { force = true })
        no_context_term_buf_id = nil
    end

    local context_text = ''
    local context_header = ''
    local current_file = vim.fn.expand('%:p')
    if config.context_method == 'path' then
        context_header = '# Context from file path\n'
        if vim.fn.mode():find('[vV]') then
            vim.cmd('normal !')
            local start_pos = vim.api.nvim_buf_get_mark(0, '<')
            local end_pos = vim.api.nvim_buf_get_mark(0, '>')
            context_text = '@' .. current_file .. ' lines:' .. start_pos[1] .. '-' .. end_pos[1]
        else
            context_text = '@' .. current_file
        end
    else
        if vim.fn.mode():find('[vV]') then
            vim.cmd('normal !')
            context_text = M.get_visual_selection()
            context_header = '# Context selected from ' .. current_file .. '\n'
        else
            context_text = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), '\n')
            context_header = '# Context ' .. current_file .. '\n'
        end
    end

    local rules_text = ''
    if config.rules_path and vim.fn.filereadable(config.rules_path) == 1 then
        local rules_content
        if config.context_method == 'path' then
            rules_content = '@' .. config.rules_path
        else
            rules_content = table.concat(vim.fn.readfile(config.rules_path), '\n')
        end
        rules_text = '# Rules\n' .. rules_content .. '\n\n'
    end

    local initial_prompt = rules_text .. context_header .. context_text .. '\n# Task\nThis is your context, wait for commands\n\n'
    local command_to_run = 'cursor-agent ' .. vim.fn.shellescape(initial_prompt)

    context_term_buf_id = create_terminal_split(command_to_run, "Cursor Chat")
end

function M.open_cursor_terminal_no_context()
    if no_context_term_buf_id and vim.api.nvim_buf_is_valid(no_context_term_buf_id) then
        local win_id = vim.fn.bufwinid(no_context_term_buf_id)
        if win_id ~= -1 then
            vim.api.nvim_set_current_win(win_id)
            vim.cmd('startinsert')
            return
        else
            vim.api.nvim_buf_delete(no_context_term_buf_id, { force = true })
            no_context_term_buf_id = nil
        end
    end
    if context_term_buf_id and vim.api.nvim_buf_is_valid(context_term_buf_id) then
        vim.api.nvim_buf_delete(context_term_buf_id, { force = true })
        context_term_buf_id = nil
    end

    local command_to_run = 'cursor-agent'

    no_context_term_buf_id = create_terminal_split(command_to_run, "Cursor Chat")
end

return M
