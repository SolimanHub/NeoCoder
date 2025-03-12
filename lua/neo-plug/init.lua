local M = {}

local function transform_line()
    local line = vim.api.nvim_get_current_line()
    local pattern = "^##ia: "
    
    if line:match(pattern) then
        local text = line:sub(#pattern + 1)
        local row = vim.api.nvim_win_get_cursor(0)[1] - 1
        
        -- Borrar línea actual
        vim.api.nvim_buf_set_lines(0, row, row + 1, false, {})
        
        -- Insertar 3 líneas con el texto
        vim.api.nvim_buf_set_lines(0, row, row, false, {text, text, text})
        
        -- Posicionar cursor al final de la tercera línea
        local last_line = row + 2
        vim.api.nvim_win_set_cursor(0, {last_line + 1, #text})
    end
end

function M.setup()
    vim.api.nvim_create_autocmd("InsertCharPre", {
        pattern = "*",
        callback = function()
            local char = vim.v.char
            if char == "\r" then -- Detectar Enter
                vim.defer_fn(transform_line, 10)
            end
        end
    })
end

return M

