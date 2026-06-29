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
