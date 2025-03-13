local M = {}

-- Configuración de Ollama (ajusta según tu setup)
local ollama_host = "http://localhost:11434"
local model_name = "qwen2.5-coder:14b"

local function get_buffer_content()
    return vim.api.nvim_buf_get_lines(0, 0, -1, false)
end

local function query_ollama(prompt, context, cb)
    local http = require("plenary.curl").request
    local full_prompt = string.format(
        "[[INSTRUCCIONES ESTRICTAS]]\n"..
        "1. SOLO RESPONDE CON EL CÓDIGO REQUERIDO\n"..
        "2. SIN EXPLICACIONES\n"..
        "3. SIN MARCADORES ```\n"..
        "4. MANTENER ESTILO EXISTENTE\n"..
        "5. INSERTAR SOLO DONDE ESTÁ EL MARCADOR ##ia:\n\n"..
        "== CONTEXTO ACTUAL ==\n%s\n\n"..
        "== PETICIÓN ==\n%s\n\n"..
        "== EJEMPLO DE RESPUESTA CORRECTA ==\n"..
        "Entrada: '##ia: agregar resta'\n"..
        "Salida:\nresta=$((num1 - num2))\necho \"Resultado resta: $resta\"\n\n"..
        "== TU RESPUESTA DEBE SER ==\n",
        table.concat(context, "\n"),
        prompt
    )

    local original_row = vim.api.nvim_win_get_cursor(0)[1] - 1

    http({
        url = ollama_host .. "/api/generate",
        method = "post",
        headers = { ["Content-Type"] = "application/json" },
        body = vim.fn.json_encode({
            model = model_name,
            prompt = full_prompt,
            stream = false,
            options = {
                temperature = 0.1
            }
        }),
        callback = vim.schedule_wrap(function(response)
            if response.status == 200 then
                local ok, data = pcall(vim.fn.json_decode, response.body)
                
                if ok and data.response then
                    -- Limpieza agresiva de la respuesta
                    local clean_response = data.response
                        :gsub("```.-[\r\n]+", "")  
                        :gsub("#.-\n", "")         
                        :gsub("\n+", "\n")         
                    
                    -- Dividir y filtrar líneas válidas
                    local lines = vim.split(clean_response:gsub("\r", ""), "\n")
                    local filtered_lines = {}
                    
                    for _, line in ipairs(lines) do
                        if line:match("%S") and  
                           not line:match("^Aqu[ií]") and 
                           not line:match("En este c[oó]digo") then
                            table.insert(filtered_lines, line)
                        end
                    end

                    if #filtered_lines > 0 then
                        vim.api.nvim_buf_set_lines(0, original_row, original_row, false, filtered_lines)
                        vim.api.nvim_win_set_cursor(0, {original_row + #filtered_lines + 1, 0})
                    else
                        vim.notify("Respuesta no contenía código válido", vim.log.levels.WARN)
                    end
                end
            end
        end)
    })
end


local function transform_line()
    local row = vim.api.nvim_win_get_cursor(0)[1] - 1
    local line = vim.api.nvim_buf_get_lines(0, row, row + 1, false)[1]
    
    if line and line:match("##ia: ") then
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

