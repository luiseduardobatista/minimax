-- ┌─────────────────────────┐
-- │ Plugins outside of MINI │
-- └─────────────────────────┘
--
-- This file contains installation and configuration of plugins outside of MINI.
-- They significantly improve user experience in a way not yet possible with MINI.
-- These are mostly plugins that provide programming language specific behavior.
--
-- Use this file to install and configure other such plugins.

-- Make concise helpers for installing/adding plugins in two stages
local add, later, now = MiniDeps.add, MiniDeps.later, MiniDeps.now
local now_if_args = _G.Config.now_if_args

-- Tree-sitter ================================================================

-- Tree-sitter is a tool for fast incremental parsing. It converts text into
-- a hierarchical structure (called tree) that can be used to implement advanced
-- and/or more precise actions: syntax highlighting, textobjects, indent, etc.
--
-- Tree-sitter support is built into Neovim (see `:h treesitter`). However, it
-- requires two extra pieces that don't come with Neovim directly:
-- - Language parsers: programs that convert text into trees. Some are built-in
--   (like for Lua), 'nvim-treesitter' provides many others.
--   NOTE: It requires third party software to build and install parsers.
--   See the link for more info in "Requirements" section of the MiniMax README.
-- - Query files: definitions of how to extract information from trees in
--   a useful manner (see `:h treesitter-query`). 'nvim-treesitter' also provides
--   these, while 'nvim-treesitter-textobjects' provides the ones for Neovim
--   textobjects (see `:h text-objects`, `:h MiniAi.gen_spec.treesitter()`).
--
-- Add these plugins now if file (and not 'mini.starter') is shown after startup.
now_if_args(function()
  add({
    source = 'nvim-treesitter/nvim-treesitter',
    -- Update tree-sitter parser after plugin is updated
    hooks = { post_checkout = function() vim.cmd('TSUpdate') end },
  })
  add({
    source = 'nvim-treesitter/nvim-treesitter-textobjects',
    -- Use `main` branch since `master` branch is frozen, yet still default
    -- It is needed for compatibility with 'nvim-treesitter' `main` branch
    checkout = 'main',
  })

  -- Define languages which will have parsers installed and auto enabled
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
    -- Add here more languages with which you want to use tree-sitter
    -- To see available languages:
    -- - Execute `:=require('nvim-treesitter').get_available()`
    -- - Visit 'SUPPORTED_LANGUAGES.md' file at
    --   https://github.com/nvim-treesitter/nvim-treesitter/blob/main
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
  _G.Config.new_autocmd('FileType', filetypes, ts_start, 'Start tree-sitter')
end)

-- Language servers ===========================================================

-- Language Server Protocol (LSP) is a set of conventions that power creation of
-- language specific tools. It requires two parts:
-- - Server - program that performs language specific computations.
-- - Client - program that asks server for computations and shows results.
--
-- Here Neovim itself is a client (see `:h vim.lsp`). Language servers need to
-- be installed separately based on your OS, CLI tools, and preferences.
--
-- Neovim's team collects commonly used configurations for most language servers
-- inside 'neovim/nvim-lspconfig' plugin.
--
-- Add it now if file (and not 'mini.starter') is shown after startup.
now_if_args(function()
  add('neovim/nvim-lspconfig')

  vim.lsp.config('ruff', {
    on_attach = function(client, bufnr)
      client.server_capabilities.hoverProvider = false
    end,
  })

  now_if_args(function()
    add('williamboman/mason.nvim')
    add('WhoIsSethDaniel/mason-tool-installer.nvim')
    require('mason').setup()
    require('mason-tool-installer').setup({
      ensure_installed = {
        -- LSP
        'lua-language-server',
        'gopls',
        'basedpyright',
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

  -- Use `:h vim.lsp.enable()` to automatically enable language server based on
  -- the rules provided by 'nvim-lspconfig'.
  -- Use `:h vim.lsp.config()` or 'after/lsp/' directory to configure servers.
  -- Uncomment and tweak the following `vim.lsp.enable()` call to enable servers.
  vim.lsp.enable({
    'lua_ls',
    'basedpyright',
    'ruff',
    'gopls',
    'nil_ls',
  })
end)

-- Formatting =================================================================

-- Programs dedicated to text formatting (a.k.a. formatters) are very useful.
-- Neovim has built-in tools for text formatting (see `:h gq` and `:h 'formatprg'`).
-- They can be used to configure external programs, but it might become tedious.
--
-- The 'stevearc/conform.nvim' plugin is a good and maintained solution for easier
-- formatting setup.
later(function()
  add('stevearc/conform.nvim')

  -- See also:
  -- - `:h Conform`
  -- - `:h conform-options`
  -- - `:h conform-formatters`
  require('conform').setup({
    -- Map of filetype to formatters
    -- Make sure that necessary CLI tool is available
    formatters_by_ft = {
      lua = { 'stylua' },
      nix = { 'alejandra' },
      python = { 'ruff_organize_imports', 'ruff_format' },
    },
    format_on_save = { lsp_fallback = true, timeout_ms = 500 },
  })
end)

-- Snippets ===================================================================

-- Although 'mini.snippets' provides functionality to manage snippet files, it
-- deliberately doesn't come with those.
--
-- The 'rafamadriz/friendly-snippets' is currently the largest collection of
-- snippet files. They are organized in 'snippets/' directory (mostly) per language.
-- 'mini.snippets' is designed to work with it as seamlessly as possible.
-- See `:h MiniSnippets.gen_loader.from_lang()`.
later(function() add('rafamadriz/friendly-snippets') end)

now_if_args(function() add('olexsmir/gopher.nvim') end, function()
  local gopher_loaded = false
  vim.api.nvim_create_autocmd('FileType', {
    pattern = 'go',
    callback = function()
      if not gopher_loaded then
        require('gopher').setup({
          commands = {
            gotests = 'gotestsum',
          },
        })
        gopher_loaded = true
      end
    end,
  })
end)

now_if_args(function()
  add('folke/snacks.nvim')
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

later(
  function()
    add({
      source = 'ThePrimeagen/refactoring.nvim',
      depends = {
        'nvim-lua/plenary.nvim',
        'nvim-treesitter/nvim-treesitter',
      },
    })
  end
)

later(function()
  add('stevearc/quicker.nvim')
  require('quicker').setup({
    keys = {
      {
        '>',
        function()
          require('quicker').expand({ before = 2, after = 2, add_to_existing = true })
        end,
        desc = 'Expand quickfix context',
      },
      {
        '<',
        function() require('quicker').collapse() end,
        desc = 'Collapse quickfix context',
      },
    },
  })
end)

later(function()
  add({
    source = 'saghen/blink.cmp',
    depends = { 'rafamadriz/friendly-snippets' },
    checkout = 'v1.8.0',
  })
  local blink = require('blink.cmp')
  blink.setup({
    snippets = {
      preset = 'default',
    },
    appearance = {
      use_nvim_cmp_as_default = false,
      nerd_font_variant = 'mono',
    },
    completion = {
      accept = {
        auto_brackets = {
          enabled = true,
        },
      },
      menu = {
        border = 'none',
        draw = {
          columns = {
            { 'label', 'label_description', gap = 1 },
            { 'kind_icon', 'kind', gap = 1 },
          },
        },
      },
      documentation = {
        auto_show = false,
      },
      ghost_text = {
        enabled = true,
      },
    },
    sources = {
      default = { 'lsp', 'path', 'snippets' },
    },
    cmdline = {
      keymap = {
        preset = 'cmdline',
      },
      completion = {
        list = { selection = { preselect = false } },
        menu = {
          auto_show = function(ctx) return vim.fn.getcmdtype() == ':' end,
        },
      },
    },
    signature = { enabled = true },
    keymap = {
      preset = 'enter',
      ['<C-y>'] = { 'select_and_accept' },
      ['<C-d>'] = { 'show', 'show_documentation', 'hide_documentation' },
      ['<Tab>'] = { 'snippet_forward', 'select_next', 'fallback' },
      ['<S-Tab>'] = { 'snippet_backward', 'select_prev', 'fallback' },
    },
  })
  vim.lsp.config('*', {
    capabilities = require('blink.cmp').get_lsp_capabilities(),
  })
end)

now(function()
  add('mrjones2014/smart-splits.nvim')
  require('smart-splits').setup()

  -- resizing splits
  -- these keymaps will also accept a range,
  -- for example `10<A-h>` will `resize_left` by `(10 * config.default_amount)`
  vim.keymap.set('n', '<A-h>', require('smart-splits').resize_left)
  vim.keymap.set('n', '<A-j>', require('smart-splits').resize_down)
  vim.keymap.set('n', '<A-k>', require('smart-splits').resize_up)
  vim.keymap.set('n', '<A-l>', require('smart-splits').resize_right)
  -- moving between splits
  vim.keymap.set('n', '<C-h>', require('smart-splits').move_cursor_left)
  vim.keymap.set('n', '<C-j>', require('smart-splits').move_cursor_down)
  vim.keymap.set('n', '<C-k>', require('smart-splits').move_cursor_up)
  vim.keymap.set('n', '<C-l>', require('smart-splits').move_cursor_right)
  vim.keymap.set('n', '<C-\\>', require('smart-splits').move_cursor_previous)
  -- swapping buffers between windows
  vim.keymap.set('n', '<leader><leader>h', require('smart-splits').swap_buf_left)
  vim.keymap.set('n', '<leader><leader>j', require('smart-splits').swap_buf_down)
  vim.keymap.set('n', '<leader><leader>k', require('smart-splits').swap_buf_up)
  vim.keymap.set('n', '<leader><leader>l', require('smart-splits').swap_buf_right)
end)

-- Beautiful, usable, well maintained color schemes outside of 'mini.nvim' and
-- have full support of its highlight groups. Use if you don't like 'miniwinter'
-- enabled in 'plugin/30_mini.lua' or other suggested 'mini.hues' based ones.
now(function()
  -- Install only those that you need
  add('rose-pine/neovim')
  require('rose-pine').setup({
    styles = {
      bold = true,
      italic = false,
      transparency = true,
    },
  })

  add('vague-theme/vague.nvim')
  require('vague').setup({
    transparent = false,
    italic = false,
  })

  vim.cmd('colorscheme vague')
  vim.api.nvim_set_hl(0, 'MiniPickMatchCurrent', { link = 'Visual' })
end)
