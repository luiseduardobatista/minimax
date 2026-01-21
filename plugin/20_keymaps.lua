-- ┌─────────────────┐
-- │ Custom mappings │
-- └─────────────────┘
--
-- This file contains definitions of custom general and Leader mappings.

-- General mappings ===========================================================

-- Use this section to add custom general mappings. See `:h vim.keymap.set()`.

-- An example helper to create a Normal mode mapping
local nmap = function(lhs, rhs, desc)
  -- See `:h vim.keymap.set()`
  vim.keymap.set('n', lhs, rhs, { desc = desc })
end

-- Paste linewise before/after current line
-- Usage: `yiw` to yank a word and `]p` to put it on the next line.
nmap('[p', '<Cmd>exe "put! " . v:register<CR>', 'Paste Above')
nmap(']p', '<Cmd>exe "put "  . v:register<CR>', 'Paste Below')
nmap('<C-d>', '<C-d>zz', 'Scroll Down & Center')
nmap('<C-u>', '<C-u>zz', 'Scroll Up & Center')
nmap('<C-t>', '<C-t>zz', 'Pop Tag & Center')
nmap('<C-o>', '<C-o>zz', 'Jump Back & Center')
nmap('<C-i>', '<C-i>zz', 'Jump Forward & Center')
nmap('<Esc>', '<Cmd>nohlsearch<CR>', 'Clear highlight')

-- Window mappings ===========================================================
nmap('<leader>-', '<C-W>s', 'Split Window Below')
nmap('<leader>|', '<C-W>v', 'Split Window Right')
nmap('<leader>wd', '<C-W>c', 'Delete Current Window')

local map_expr = function(mode, lhs, rhs, desc)
  vim.keymap.set(mode, lhs, rhs, { expr = true, desc = desc })
end

-- Saner behavior of n and N (https://github.com/mhinz/vim-galore#saner-behavior-of-n-and-n)
map_expr('n', 'n', "'Nn'[v:searchforward].'zv'", 'Next Search Result')
map_expr('x', 'n', "'Nn'[v:searchforward]", 'Next Search Result')
map_expr('o', 'n', "'Nn'[v:searchforward]", 'Next Search Result')
map_expr('n', 'N', "'nN'[v:searchforward].'zv'", 'Prev Search Result')
map_expr('x', 'N', "'nN'[v:searchforward]", 'Prev Search Result')
map_expr('o', 'N', "'nN'[v:searchforward]", 'Prev Search Result')

-- Many general mappings are created by 'mini.basics'. See 'plugin/30_mini.lua'

-- stylua: ignore start
-- The next part (until `-- stylua: ignore end`) is aligned manually for easier
-- reading. Consider preserving this or remove `-- stylua` lines to autoformat.

-- Leader mappings ============================================================

-- Neovim has the concept of a Leader key (see `:h <Leader>`). It is a configurable
-- key that is primarily used for "workflow" mappings (opposed to text editing).
-- Like "open file explorer", "create scratch buffer", "pick from buffers".
--
-- In 'plugin/10_options.lua' <Leader> is set to <Space>, i.e. press <Space>
-- whenever there is a suggestion to press <Leader>.
--
-- This config uses a "two key Leader mappings" approach: first key describes
-- semantic group, second key executes an action. Both keys are usually chosen
-- to create some kind of mnemonic.
-- Example: `<Leader>f` groups "find" type of actions; `<Leader>ff` - find files.
-- Use this section to add Leader mappings in a structural manner.
--
-- Usually if there are global and local kinds of actions, lowercase second key
-- denotes global and uppercase - local.
-- Example: `<Leader>fs` / `<Leader>fS` - find workspace/document LSP symbols.
--
-- Many of the mappings use 'mini.nvim' modules set up in 'plugin/30_mini.lua'.

-- Create a global table with information about Leader groups in certain modes.
-- This is used to provide 'mini.clue' with extra clues.
-- Add an entry if you create a new group.
_G.Config.leader_group_clues = {
  { mode = 'n', keys = '<Leader>b', desc = '+Buffer' },
  { mode = 'n', keys = '<Leader>e', desc = '+Explore/Edit' },
  { mode = 'n', keys = '<Leader>f', desc = '+Find' },
  { mode = 'n', keys = '<Leader>g', desc = '+Git' },
  -- { mode = 'n', keys = '<Leader>l', desc = '+Language' },
  { mode = 'n', keys = '<Leader>m', desc = '+Map' },
  { mode = 'n', keys = '<Leader>o', desc = '+Other' },
  { mode = 'n', keys = '<Leader>s', desc = '+Session' },
  { mode = 'n', keys = '<Leader>t', desc = '+Terminal' },
  { mode = 'n', keys = '<Leader>v', desc = '+Visits' },
  { mode = 'n', keys = '<Leader>w', desc = '+Window' },

  { mode = 'x', keys = '<Leader>g', desc = '+Git' },
  -- { mode = 'x', keys = '<Leader>l', desc = '+Language' },
}

-- Helpers for a more concise `<Leader>` mappings.
-- Most of the mappings use `<Cmd>...<CR>` string as a right hand side (RHS) in
-- an attempt to be more concise yet descriptive. See `:h <Cmd>`.
-- This approach also doesn't require the underlying commands/functions to exist
-- during mapping creation: a "lazy loading" approach to improve startup time.
local nmap_leader = function(suffix, rhs, desc, expr, silent)
  vim.keymap.set('n', '<Leader>' .. suffix, rhs, { desc = desc, expr = expr, silent = silent or false})
end
local xmap_leader = function(suffix, rhs, desc, expr, silent)
  vim.keymap.set('x', '<Leader>' .. suffix, rhs, { desc = desc, expr = expr, silent = silent or false })
end

-- b is for 'Buffer'. Common usage:
-- - `<Leader>bs` - create scratch (temporary) buffer
-- - `<Leader>ba` - navigate to the alternative buffer
-- - `<Leader>bw` - wipeout (fully delete) current buffer
local new_scratch_buffer = function()
  vim.api.nvim_win_set_buf(0, vim.api.nvim_create_buf(true, true))
end

nmap_leader('ba', '<Cmd>b#<CR>',                                 'Alternate')
nmap_leader('bd', '<Cmd>lua MiniBufremove.delete()<CR>',         'Delete')
nmap_leader('bD', '<Cmd>lua MiniBufremove.delete(0, true)<CR>',  'Delete!')
nmap_leader('bs', new_scratch_buffer,                            'Scratch')
nmap_leader('bw', '<Cmd>lua MiniBufremove.wipeout()<CR>',        'Wipeout')
nmap_leader('bW', '<Cmd>lua MiniBufremove.wipeout(0, true)<CR>', 'Wipeout!')
nmap_leader('bc', '<Cmd>CopyBufferContent<CR>',                  'Copy buffer content', nil, true)

-- e is for 'Explore' and 'Edit'. Common usage:
-- - `<Leader>ed` - open explorer at current working directory
-- - `<Leader>ef` - open directory of current file (needs to be present on disk)
-- - `<Leader>ei` - edit 'init.lua'
-- - All mappings that use `edit_plugin_file` - edit 'plugin/' config files
local edit_plugin_file = function(filename)
  return string.format('<Cmd>edit %s/plugin/%s<CR>', vim.fn.stdpath('config'), filename)
end
local explore_at_file = '<Cmd>lua MiniFiles.open(vim.api.nvim_buf_get_name(0))<CR>'
local explore_quickfix = function()
  return vim.fn.getqflist({ winid = true }).winid ~= 0
    and vim.cmd('cclose')
    or vim.diagnostic.setqflist({ open = true, title = 'Workspace Diagnostics' })
end
local explore_locations = function()
  return vim.fn.getloclist(0, { winid = true }).winid ~= 0
    and vim.cmd('lclose')
    or vim.diagnostic.setloclist({ open = true, title = 'Buffer Diagnostics' })
end

nmap_leader('ed', '<Cmd>lua MiniFiles.open()<CR>',          'Directory')
nmap_leader('ef', explore_at_file,                          'File directory')
nmap_leader('ei', '<Cmd>edit $MYVIMRC<CR>',                 'init.lua')
nmap_leader('ek', edit_plugin_file('20_keymaps.lua'),       'Keymaps config')
nmap_leader('em', edit_plugin_file('30_mini.lua'),          'MINI config')
nmap_leader('en', '<Cmd>lua MiniNotify.show_history()<CR>', 'Notifications')
nmap_leader('eo', edit_plugin_file('10_options.lua'),       'Options config')
nmap_leader('ep', edit_plugin_file('40_plugins.lua'),       'Plugins config')
nmap_leader('eq', explore_quickfix,                         'Quickfix list')
nmap_leader('el', explore_locations,                        'Location list')

-- f is for 'Fuzzy Find'. Common usage:
-- - `<Leader>ff` - find files; for best performance requires `ripgrep`
-- - `<Leader>fg` - find inside files; requires `ripgrep`
-- - `<Leader>fh` - find help tag
-- - `<Leader>fr` - resume latest picker
-- - `<Leader>fv` - all visited paths; requires 'mini.visits'
--
-- All these use 'mini.pick'. See `:h MiniPick-overview` for an overview.
local pick_added_hunks_buf = '<Cmd>Pick git_hunks path="%" scope="staged"<CR>'
local pick_workspace_symbols_live = '<Cmd>Pick lsp scope="workspace_symbol_live"<CR>'

local make_pick_recent = function(cwd, desc)
  return function()
    local sort_recent = MiniVisits.gen_sort.default({ recency_weight = 1, freq_weight = 0 })
    local current_path = vim.fn.expand('%:p')
    local filter_exclude_current = function(path_data)
      return path_data.path ~= current_path
    end
    MiniExtra.pickers.visit_paths(
      { cwd = cwd, sort = sort_recent, filter = filter_exclude_current },
      { source = { name = desc } }
    )
  end
end

local safe_resume = function()
  local success = pcall(MiniPick.resume)
  if not success then
    vim.notify('Nenhum picker anterior para resumir.', vim.log.levels.WARN)
  end
end


nmap_leader('f/', '<Cmd>Pick history scope="/"<CR>',            '"/" history')
nmap_leader('f:', '<Cmd>Pick history scope=":"<CR>',            '":" history')
nmap_leader('fa', '<Cmd>Pick git_hunks scope="staged"<CR>',     'Added hunks (all)')
nmap_leader('fA', pick_added_hunks_buf,                         'Added hunks (buf)')
nmap_leader('fb', '<Cmd>Pick buffers<CR>',                      'Buffers')
nmap_leader('fc', '<Cmd>Pick git_commits<CR>',                  'Commits (all)')
nmap_leader('fC', '<Cmd>Pick git_commits path="%"<CR>',         'Commits (buf)')
nmap_leader('fd', '<Cmd>Pick diagnostic scope="current"<CR>',   'Diagnostic buffer')
nmap_leader('fD', '<Cmd>Pick diagnostic scope="all"<CR>',       'Diagnostic workspace')
nmap_leader('ff', '<Cmd>Pick files<CR>',                        'Files')
nmap_leader('fg', '<Cmd>Pick grep_live<CR>',                    'Grep live')
nmap_leader('fG', '<Cmd>Pick grep pattern="<cword>"<CR>',       'Grep current word')
nmap_leader('fp', '<Cmd>Pick grep<CR>',                         'Grep (Pattern -> Fuzzy)')
nmap_leader('fh', '<Cmd>Pick help<CR>',                         'Help tags')
nmap_leader('fH', '<Cmd>Pick hl_groups<CR>',                    'Highlight groups')
nmap_leader('fl', '<Cmd>Pick buf_lines scope="all"<CR>',        'Lines (all)')
nmap_leader('fL', '<Cmd>Pick buf_lines scope="current"<CR>',    'Lines (buf)')
nmap_leader('fm', '<Cmd>Pick git_hunks<CR>',                    'Modified hunks (all)')
nmap_leader('fM', '<Cmd>Pick git_hunks path="%"<CR>',           'Modified hunks (buf)')
nmap_leader('fr', safe_resume,                       'Resume')
nmap_leader('fs', pick_workspace_symbols_live,                  'Symbols workspace (live)')
nmap_leader('fS', '<Cmd>Pick lsp scope="document_symbol"<CR>',  'Symbols document')
nmap_leader('fv', make_pick_recent(nil, 'Visit paths (cwd/recent)'), 'Visit paths (cwd)')
nmap_leader('fV', make_pick_recent('',  'Visit paths (all/recent)'), 'Visit paths (all)')

-- g is for 'Git'. Common usage:
-- - `<Leader>gs` - show information at cursor
-- - `<Leader>go` - toggle 'mini.diff' overlay to show in-buffer unstaged changes
-- - `<Leader>gd` - show unstaged changes as a patch in separate tabpage
-- - `<Leader>gL` - show Git log of current file
local git_log_cmd = [[Git log --pretty=format:\%h\ \%as\ │\ \%s --topo-order]]
local git_log_buf_cmd = git_log_cmd .. ' --follow -- %'

nmap_leader('ga', '<Cmd>Git diff --cached<CR>',             'Added diff')
nmap_leader('gA', '<Cmd>Git diff --cached -- %<CR>',        'Added diff buffer')
nmap_leader('gc', '<Cmd>Git commit<CR>',                    'Commit')
nmap_leader('gC', '<Cmd>Git commit --amend<CR>',            'Commit amend')
nmap_leader('gd', '<Cmd>Git diff<CR>',                      'Diff')
nmap_leader('gD', '<Cmd>Git diff -- %<CR>',                 'Diff buffer')
nmap_leader('gl', '<Cmd>' .. git_log_cmd .. '<CR>',         'Log')
nmap_leader('gL', '<Cmd>' .. git_log_buf_cmd .. '<CR>',     'Log buffer')
nmap_leader('go', '<Cmd>lua MiniDiff.toggle_overlay()<CR>', 'Toggle overlay')
nmap_leader('gs', '<Cmd>lua MiniGit.show_at_cursor()<CR>',  'Show at cursor')
nmap_leader('gg', '<Cmd>lua Snacks.lazygit()<CR>',                 'Open LazyGit')

xmap_leader('gs', '<Cmd>lua MiniGit.show_at_cursor()<CR>', 'Show at selection')

-- l is for 'Language'. Common usage:
-- - `<Leader>ld` - show more diagnostic details in a floating window
-- - `<Leader>lr` - perform rename via LSP
-- - `<Leader>ls` - navigate to source definition of symbol under cursor
--
-- NOTE: most LSP mappings represent a more structured way of replacing built-in
-- LSP mappings (like `:h gra` and others). This is needed because `gr` is mapped
-- by an "replace" operator in 'mini.operators' (which is more commonly used).

nmap_leader('a', '<Cmd>lua vim.lsp.buf.code_action()<CR>',      'Actions')
nmap_leader('d', '<Cmd>lua vim.diagnostic.open_float()<CR>',    'Diagnostic popup')
nmap_leader('F', '<Cmd>lua require("conform").format()<CR>',    'Format')
nmap_leader('r', '<Cmd>lua vim.lsp.buf.rename()<CR>',           'Rename')

pcall(vim.keymap.del, 'n', 'grt')
pcall(vim.keymap.del, 'n', 'gri')
pcall(vim.keymap.del, 'n', 'grr')
pcall(vim.keymap.del, 'n', 'gra')
pcall(vim.keymap.del, 'n', 'grn')

local on_list = function(scope)
  return function(opts)
    if #opts.items == 1 then
      vim.lsp.util.show_document(opts.items[1].user_data, 'utf-8')
      vim.cmd('normal! zz')
    else
      require('mini.extra').pickers.lsp({ scope = scope })
    end
  end
end

nmap('gd', function() vim.lsp.buf.definition({ on_list = on_list('definition') }) end,      'LSP Definition')
nmap('gd', function() vim.lsp.buf.definition({ on_list = on_list('definition') }) end,      'LSP Definition')
nmap('gD', function() vim.lsp.buf.declaration({ on_list = on_list('declaration') }) end,     'LSP Declaration')
nmap('gI', function() vim.lsp.buf.implementation({ on_list = on_list('implementation') }) end, 'LSP Implementation')
nmap('gy', function() vim.lsp.buf.type_definition({ on_list = on_list('type_definition') }) end, 'LSP Type Definition')
nmap('gr', function() vim.lsp.buf.references(nil, { on_list = on_list('references') }) end,      'LSP References')

nmap('K',  '<Cmd>lua vim.lsp.buf.hover()<CR>',           'LSP Hover')
nmap('<C-k>', '<Cmd>lua vim.lsp.buf.signature_help()<CR>', 'LSP Signature Help')

xmap_leader('F', '<Cmd>lua require("conform").format()<CR>', 'Format selection')

-- m is for 'Map'. Common usage:
-- - `<Leader>mt` - toggle map from 'mini.map' (closed by default)
-- - `<Leader>mf` - focus on the map for fast navigation
-- - `<Leader>ms` - change map's side (if it covers something underneath)
nmap_leader('mf', '<Cmd>lua MiniMap.toggle_focus()<CR>', 'Focus (toggle)')
nmap_leader('mr', '<Cmd>lua MiniMap.refresh()<CR>',      'Refresh')
nmap_leader('ms', '<Cmd>lua MiniMap.toggle_side()<CR>',  'Side (toggle)')
nmap_leader('mt', '<Cmd>lua MiniMap.toggle()<CR>',       'Toggle')

-- o is for 'Other'. Common usage:
-- - `<Leader>oz` - toggle between "zoomed" and regular view of current buffer
nmap_leader('or', '<Cmd>lua MiniMisc.resize_window()<CR>', 'Resize to default width')
nmap_leader('ot', '<Cmd>lua MiniTrailspace.trim()<CR>',    'Trim trailspace')
nmap_leader('oz', '<Cmd>lua MiniMisc.zoom()<CR>',          'Zoom toggle')
nmap_leader('oe', ':DeleteBlankLines<CR>', 'Delete empty lines')
xmap_leader('oe', ':DeleteBlankLines<CR>',   'Delete empty lines')
nmap_leader('oc', '<Cmd>RemoveComments<CR>',               'Remove comments')
xmap_leader('oc', ':RemoveComments<CR>',                   'Remove comments')

-- s is for 'Session'. Common usage:
-- - `<Leader>sn` - start new session
-- - `<Leader>sr` - read previously started session
-- - `<Leader>sd` - delete previously started session
local session_new = 'MiniSessions.write(vim.fn.input("Session name: "))'

nmap_leader('sd', '<Cmd>lua MiniSessions.select("delete")<CR>', 'Delete')
nmap_leader('sn', '<Cmd>lua ' .. session_new .. '<CR>',         'New')
nmap_leader('sr', '<Cmd>lua MiniSessions.select("read")<CR>',   'Read')
nmap_leader('sw', '<Cmd>lua MiniSessions.write()<CR>',          'Write current')

-- t is for 'Terminal'
nmap_leader('tT', '<Cmd>horizontal term<CR>', 'Terminal (horizontal)')
nmap_leader('tt', '<Cmd>vertical term<CR>',   'Terminal (vertical)')

-- v is for 'Visits'. Common usage:
-- - `<Leader>vv` - add    "core" label to current file.
-- - `<Leader>vV` - remove "core" label to current file.
-- - `<Leader>vc` - pick among all files with "core" label.
local make_pick_core = function(cwd, desc)
  return function()
    local sort_latest = MiniVisits.gen_sort.default({ recency_weight = 1 })
    local local_opts = { cwd = cwd, filter = 'core', sort = sort_latest }
    MiniExtra.pickers.visit_paths(local_opts, { source = { name = desc } })
  end
end

nmap_leader('vc', make_pick_core('',  'Core visits (all)'),       'Core visits (all)')
nmap_leader('vC', make_pick_core(nil, 'Core visits (cwd)'),       'Core visits (cwd)')
nmap_leader('vv', '<Cmd>lua MiniVisits.add_label("core")<CR>',    'Add "core" label')
nmap_leader('vV', '<Cmd>lua MiniVisits.remove_label("core")<CR>', 'Remove "core" label')
nmap_leader('vl', '<Cmd>lua MiniVisits.add_label()<CR>',          'Add label')
nmap_leader('vL', '<Cmd>lua MiniVisits.remove_label()<CR>',       'Remove label')


-- c is for 'Code'.

-- Helper específico para Refactor com expr = true
local refactor = function(type)
  return function() require('refactoring').refactor(type) end
end

nmap_leader('cr', '<Cmd>lua require("refactoring").select_refactor()<CR>', 'Select Refactor')
xmap_leader('cr', '<Cmd>lua require("refactoring").select_refactor()<CR>', 'Select Refactor')
nmap_leader('ci', refactor('Inline Variable'),            'Inline variable',        true)
xmap_leader('ci', refactor('Inline Variable'),            'Inline variable',        true)
nmap_leader('cb', refactor('Extract Block'),              'Extract block',          true)
nmap_leader('cB', refactor('Extract Block To File'),      'Extract block to file',  true)
nmap_leader('ce', refactor('Extract Function'),           'Extract function',       true)
xmap_leader('ce', refactor('Extract Function'),           'Extract function',       true)
nmap_leader('cf', refactor('Extract Function To File'),   'Extract func to file',   true)
xmap_leader('cf', refactor('Extract Function To File'),   'Extract func to file',   true)
nmap_leader('cv', refactor('Extract Variable'),           'Extract variable',       true)
xmap_leader('cv', refactor('Extract Variable'),           'Extract variable',       true)
nmap_leader('cI', refactor('Inline Function'), 'Inline function', true)
xmap_leader('cI', refactor('Inline Function'), 'Inline function', true)
-- stylua: ignore end
