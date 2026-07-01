local add = vim.pack.add
local now_if_args, later = Config.now_if_args, Config.later

now_if_args(function()
  -- Define hook to update tree-sitter parsers after plugin is updated
  local ts_update = function() vim.cmd('TSUpdate') end
  Config.on_packchanged('nvim-treesitter', { 'update' }, ts_update, ':TSUpdate')

  add({
    'https://github.com/nvim-treesitter/nvim-treesitter',
    'https://github.com/nvim-treesitter/nvim-treesitter-textobjects',
  })

  local languages = {
    -- These are already pre-installed with Neovim. Used as an example.
    'lua',
    'vimdoc',
    'markdown',

    'python',
    'go',
    'rust',
    'html',
    'css',
    'json',
    'dockerfile',
    'nix',
  }
  local isnt_installed = function(lang)
    return #vim.api.nvim_get_runtime_file('parser/' .. lang .. '.*', false) == 0
  end
  local to_install = vim.tbl_filter(isnt_installed, languages)
  if #to_install > 0 then require('nvim-treesitter').install(to_install) end

  -- Enable tree-sitter after opening a file for a target language
  local filetypes = {}
  for _, lang in ipairs(languages) do
    for _, ft in ipairs(vim.treesitter.language.get_filetypes(lang)) do
      table.insert(filetypes, ft)
    end
  end
  local ts_start = function(ev) vim.treesitter.start(ev.buf) end
  Config.new_autocmd('FileType', filetypes, ts_start, 'Start tree-sitter')
end)

now_if_args(function()
  add({ 'https://github.com/neovim/nvim-lspconfig' })
  vim.lsp.enable({
    'lua_ls',
    'ty',
    'ruff',
    'gopls',
    'nil_ls',
  })
end)

later(function()
  add({ 'https://github.com/williamboman/mason.nvim' })
  add({ 'https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim' })
  require('mason').setup()
  require('mason-tool-installer').setup({
    ensure_installed = {
      -- LSP
      'lua-language-server',
      'gopls',
      'nil',
      'ty',

      -- Formatters/Linters
      'stylua',
      'gofumpt',
      'ruff',
      'alejandra',
    },
  })
end)

later(function()
  add({ 'https://github.com/stevearc/conform.nvim' })
  require('conform').setup({
    formatters_by_ft = {
      lua = { 'stylua' },
      nix = { 'alejandra' },
      python = { 'ruff_organize_imports', 'ruff_format' },
      go = { 'gofmt' },
      kdl = { 'kdlfmt' },
    },
    format_on_save = { lsp_fallback = true, timeout_ms = 500 },
  })
end)

later(function() add({ 'https://github.com/rafamadriz/friendly-snippets' }) end)

now_if_args(function()
  add({ 'https://github.com/mrjones2014/smart-splits.nvim' })
  require('smart-splits').setup()

  vim.keymap.set('n', '<C-S-h>', require('smart-splits').resize_left)
  vim.keymap.set('n', '<C-S-j>', require('smart-splits').resize_down)
  vim.keymap.set('n', '<C-S-k>', require('smart-splits').resize_up)
  vim.keymap.set('n', '<C-S-l>', require('smart-splits').resize_right)

  vim.keymap.set('n', '<C-h>', require('smart-splits').move_cursor_left)
  vim.keymap.set('n', '<C-j>', require('smart-splits').move_cursor_down)
  vim.keymap.set('n', '<C-k>', require('smart-splits').move_cursor_up)
  vim.keymap.set('n', '<C-l>', require('smart-splits').move_cursor_right)
  vim.keymap.set('n', '<C-\\>', require('smart-splits').move_cursor_previous)

  vim.keymap.set('n', '<leader><leader>h', require('smart-splits').swap_buf_left)
  vim.keymap.set('n', '<leader><leader>j', require('smart-splits').swap_buf_down)
  vim.keymap.set('n', '<leader><leader>k', require('smart-splits').swap_buf_up)
  vim.keymap.set('n', '<leader><leader>l', require('smart-splits').swap_buf_right)
end)

now_if_args(function()
  add({
    'https://github.com/saghen/blink.cmp',
  })
  local blink = require('blink.cmp')
  blink.setup({
    completion = {
      accept = {
        auto_brackets = { enabled = true },
      },
      menu = {
        draw = {
          treesitter = { 'lsp' },
          columns = {
            { 'label', 'label_description', gap = 1 },
            { 'kind' },
          },
        },
      },
      documentation = {
        auto_show = true,
        auto_show_delay_ms = 100,
      },
      ghost_text = { enabled = true },
    },
    cmdline = {
      enabled = false,
    },
    signature = {
      enabled = true,
    },
    keymap = {
      preset = 'enter',
      ['<C-y>'] = { 'select_and_accept' },
      ['<C-u>'] = { 'scroll_signature_up', 'scroll_documentation_up', 'fallback' },
      ['<C-d>'] = {
        'scroll_signature_down',
        'scroll_documentation_down',
        'fallback',
      },
    },
  })
end)

now_if_args(function()
  add({ 'https://github.com/folke/snacks.nvim' })
  require('snacks').setup({
    lazygit = { enabled = true },
    bigfile = { enabled = false },
    dashboard = { enabled = false },
    explorer = { enabled = false },
    indent = { enabled = false },
    input = { enabled = false },
    picker = { enabled = false },
    notifier = { enabled = false },
    quickfile = { enabled = false },
    scope = { enabled = false },
    scroll = { enabled = false },
    statuscolumn = { enabled = false },
    words = { enabled = false },
  })
end)

later(function()
  add({ 'https://github.com/folke/sidekick.nvim' })
  require('sidekick').setup({
    cli = {
      mux = {
        backend = 'tmux',
        enabled = true,
        create = 'terminal',
      },
    },
  })

  vim.keymap.set({ 'i', 'n' }, '<tab>', function()
    if require('sidekick').nes_jump_or_apply() then return end
    return '<tab>'
  end, { expr = true, desc = 'Goto/Apply Next Edit Suggestion' })

  vim.keymap.set(
    { 'n', 't', 'i', 'x' },
    '<c-.>',
    function() require('sidekick.cli').focus() end,
    { desc = 'Sidekick Focus' }
  )

  vim.keymap.set(
    'n',
    '<leader>aa',
    function() require('sidekick.cli').toggle() end,
    { desc = 'Sidekick Toggle CLI' }
  )

  vim.keymap.set(
    'n',
    '<leader>as',
    function() require('sidekick.cli').select() end,
    { desc = 'Select CLI' }
  )

  vim.keymap.set(
    'n',
    '<leader>ad',
    function() require('sidekick.cli').close() end,
    { desc = 'Detach a CLI Session' }
  )

  vim.keymap.set(
    { 'x', 'n' },
    '<leader>at',
    function() require('sidekick.cli').send({ msg = '{this}' }) end,
    { desc = 'Send This' }
  )

  vim.keymap.set(
    'n',
    '<leader>af',
    function() require('sidekick.cli').send({ msg = '{file}' }) end,
    { desc = 'Send File' }
  )

  vim.keymap.set(
    'x',
    '<leader>av',
    function() require('sidekick.cli').send({ msg = '{selection}' }) end,
    { desc = 'Send Visual Selection' }
  )

  vim.keymap.set(
    { 'n', 'x' },
    '<leader>ap',
    function() require('sidekick.cli').prompt() end,
    { desc = 'Sidekick Select Prompt' }
  )

  vim.keymap.set(
    'n',
    '<leader>ac',
    function() require('sidekick.cli').toggle({ name = 'pi', focus = true }) end,
    { desc = 'Sidekick Toggle Pi' }
  )
end)
