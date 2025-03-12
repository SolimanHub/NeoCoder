local M = {}

local function transform_line()

    local row = vim.api.nvim_win_get_cursor(0)[1] - 1
    local line = vim.api.nvim_buf_get_lines(0, row, row + 1, false)[1]
    
    if line:match("##ia: ") then
        local text = line:sub(7)
        vim.api.nvim_buf_set_lines(0, row, row + 1, false, {})
        
        local new_lines = {text, text, text}
        vim.api.nvim_buf_set_lines(0, row, row, false, new_lines)
        
        vim.api.nvim_win_set_cursor(0, {row + 3, #text})
        return true
    end
    return false
end

function M.setup()
    vim.keymap.set('i', '<CR>', function()
        if not transform_line() then
            --vim.api.nvim_put({''}, 'l', true, true)
              vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<CR>', true, false, true), 'n', false)
        end
    end, {noremap = true, silent = true})
end

return M

