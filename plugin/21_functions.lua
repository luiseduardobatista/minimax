function Config.delete_blank_lines(opts)
  opts = opts or {}
  local target = (opts.range and opts.range > 0)
      and string.format('%d,%d', opts.line1, opts.line2)
    or '%'
  local lines_before = vim.api.nvim_buf_line_count(0)
  local ns = vim.api.nvim_create_namespace('CleanLines')
  local r, c = unpack(vim.api.nvim_win_get_cursor(0))
  local mark = vim.api.nvim_buf_set_extmark(0, ns, r - 1, c, {})
  vim.cmd(string.format('silent! keepjumps %sg/^\\s*$/d', target))
  local new_pos = vim.api.nvim_buf_get_extmark_by_id(0, ns, mark, {})
  if #new_pos > 0 then
    pcall(vim.api.nvim_win_set_cursor, 0, { new_pos[1] + 1, new_pos[2] })
  end
  vim.api.nvim_buf_del_extmark(0, ns, mark)
  local deleted = lines_before - vim.api.nvim_buf_line_count(0)
  if deleted > 0 then
    vim.notify(
      string.format('%d linhas vazias removidas.', deleted),
      vim.log.levels.INFO
    )
  else
    vim.notify('Nenhuma linha vazia encontrada.', vim.log.levels.WARN)
  end
end

vim.api.nvim_create_user_command('DeleteBlankLines', Config.delete_blank_lines, {
  desc = 'Remove linhas em branco mantendo a posição relativa do cursor',
  range = true,
})

function Config.copy_buffer_content()
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local content = table.concat(lines, '\n')
  vim.fn.setreg('+', content)
  vim.notify(
    string.format('Copiadas %d linhas para o clipboard.', #lines),
    vim.log.levels.INFO
  )
end

vim.api.nvim_create_user_command('CopyBufferContent', Config.copy_buffer_content, {
  desc = 'Copia o conteúdo do buffer sem mover a tela',
})
