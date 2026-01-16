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
  vim.schedule(
    function()
      vim.notify(
        string.format('Copiadas %d linhas para o clipboard.', #lines),
        vim.log.levels.INFO,
        { title = 'Clipboard' }
      )
    end
  )
end

vim.api.nvim_create_user_command('CopyBufferContent', Config.copy_buffer_content, {
  desc = 'Copia o conteúdo do buffer sem mover a tela',
})

function Config.remove_comments(opts)
  local has_ts, parser = pcall(vim.treesitter.get_parser, 0)
  if not has_ts or not parser then
    return vim.notify('Tree-sitter não disponível.', vim.log.levels.ERROR)
  end

  local query = vim.treesitter.query.get(parser:lang(), 'highlights')
  if not query then
    return vim.notify('Query de highlights indisponível.', vim.log.levels.WARN)
  end

  local root = parser:parse()[1]:root()
  local start_row, end_row = opts.line1 - 1, opts.line2
  local edits = {}

  for id, node, _ in query:iter_captures(root, 0, start_row, end_row) do
    local capture = query.captures[id]
    if capture == 'comment' or capture:find('^comment%.') then
      local sr, sc, er, ec = node:range()
      if sr >= start_row and sr < end_row then
        table.insert(edits, { sr, sc, er, ec })
      end
    end
  end

  if #edits == 0 then
    return vim.notify('Nenhum comentário encontrado.', vim.log.levels.WARN)
  end

  table.sort(
    edits,
    function(a, b) return (a[1] > b[1]) or (a[1] == b[1] and a[2] > b[2]) end
  )

  local count = 0
  for _, edit in ipairs(edits) do
    local sr, sc, er, ec = unpack(edit)

    local line = vim.api.nvim_buf_get_lines(0, sr, sr + 1, false)[1] or ''
    local is_full_line = line:sub(1, sc):match('^%s*$')

    if is_full_line then
      vim.api.nvim_buf_set_lines(0, sr, er + 1, false, {})
    else
      vim.api.nvim_buf_set_text(0, sr, sc, er, ec, {})
    end
    count = count + 1
  end

  vim.notify(
    string.format('%d comentário(s) removido(s).', count),
    vim.log.levels.INFO
  )
end

vim.api.nvim_create_user_command('RemoveComments', Config.remove_comments, {
  desc = 'Remove comentários',
  range = '%',
})
