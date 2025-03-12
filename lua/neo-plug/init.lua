local M = {}

function M.replace_or_enter()
  local line = vim.fn.getline('.')
  local pattern = "^##ia: (.+)$"
  local match = line:match(pattern)
  
  if match then
    local current_line = vim.fn.line('.') - 1  -- Convertir a índice 0-based
    -- Eliminar la línea actual
    vim.api.nvim_buf_set_lines(0, current_line, current_line + 1, false, {})
    -- Insertar 3 líneas con el contenido capturado
    local new_lines = {match, match, match}
    vim.api.nvim_buf_set_lines(0, current_line, current_line, false, new_lines)
    -- Posicionar el cursor al final de la tercera línea e ingresar a modo inserción
    vim.fn.cursor(current_line + 3, #match)  -- Línea 1-based, columna 0-based
    vim.api.nvim_feedkeys('a', 'n', true)    -- Activar modo inserción después del cursor
    return ""
  else
    return vim.api.nvim_replace_termcodes("<CR>", true, false, true)
  end
end

-- Mapear la tecla Enter en modo inserción
vim.api.nvim_set_keymap('i', '<CR>', 'v:lua.require"plugin.ia".replace_or_enter()', {expr = true, noremap = true})

return M
