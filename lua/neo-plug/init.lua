local M = {}

-- Configuración de Ollama (ajusta según tu setup)
local ollama_host = "http://localhost:11434"
local model_name = "qwen2.5-coder:14b"

local function get_buffer_content()
    return vim.api.nvim_buf_get_lines(0, 0, -1, false)
end

local function query_ollama(prompt, context, cb)
    local json = require("plenary.json")
    local http = require("plenary.curl").request

    local full_prompt = string.format(
        "Contexto del documento:\n```\n%s\n```\n\nInstrucción: %s",
        table.concat(context, "\n"),
        prompt
    )

    http({
        url = ollama_host .. "/api/generate",
        method = "post",
        headers = { ["Content-Type"] = "application/json" },
        body = json.encode({
            model = model_name,
            prompt = full_prompt,
            stream = false,
            options = { temperature = 0.7 }
        }),
        callback = function(response)
            if response.status == 200 then
                local data = json.decode(response.body)
                cb(data.response)
            else
                vim.notify("Error en la consulta a Ollama: " .. response.body, vim.log.levels.ERROR)
                cb(nil)
            end
        end
    })
end

local function transform_line()
    local row = vim.api.nvim_win_get_cursor(0)[1] - 1
    local line = vim.api.nvim_buf_get_lines(0, row, row + 1, false)[1]
    
    if line and line:match("^##ia: ") then
        local prompt = line:sub(7)
        local context = get_buffer_content()
        
        -- Eliminar la línea de instrucción
        vim.api.nvim_buf_set_lines(0, row, row + 1, false, {})
        
        query_ollama(prompt, context, function(response)
            if response then
                -- Insertar la respuesta de Ollama
                local lines = vim.split(response:gsub("\r", ""), "\n")
                vim.api.nvim_buf_set_lines(0, row, row, false, lines)
                
                -- Mover el cursor al final de la respuesta
                vim.api.nvim_win_set_cursor(0, {row + #lines + 1, 0})
            else
                vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<CR>', true, false, true), 'n', false)
            end
        end)
        
        return true
    end
    return false
end

function M.setup()
    vim.keymap.set('i', '<CR>', function()
        if not transform_line() then
            vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<CR>', true, false, true), 'n', false)
        end
    end, { noremap = true, silent = true })
end

return M

