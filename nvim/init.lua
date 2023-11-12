-- for this to work you need:
-- clipboard (wl-clipboard or xclip)
-- fd
-- ripgrep
-- very recommended: jetbrainsmono nerd font

-- line numbers
vim.opt.relativenumber = true
vim.opt.nu = true
-- static block cursor
vim.opt.guicursor = ""

-- correct indents
vim.o.tabstop = 2
vim.o.softtabstop = 2
vim.o.shiftwidth = 2
vim.opt.expandtab = true

-- persistent undo
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.local/share/nvim/undodir"
vim.opt.undofile = true

-- REBINDS
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- file tree
vim.keymap.set("n", "<leader>fl", vim.cmd.Ex)

-- move lines
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- system clipboard
vim.keymap.set("n", "<leader>y", "\"+y")
vim.keymap.set("v", "<leader>y", "\"+y")

vim.keymap.set("n", "<leader>p", "\"+p")
vim.keymap.set("v", "<leader>p", "\"+p")

-- stay in the middle while moving pages
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")

-- lazy
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)
require("lazy").setup({
  {
    "nvim-treesitter/nvim-treesitter",
    config = function()
      require 'nvim-treesitter.configs'.setup {
        ensure_installed = {},
        sync_install = false,
        auto_install = true,
        ignore_install = {},
        highlight = {
          enable = true,
          -- Disable on large files
          disable = function(lang, buf)
            local max_filesize = 100 * 1024 -- 100 KB
            local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
            if ok and stats and stats.size > max_filesize then
              return true
            end
          end,
          additional_vim_regex_highlighting = false,
        },
        indent = {
          enable = true,
        },
        autotag = {
          enable = true,
        },
      }
    end
  },
  {
    "nvim-telescope/telescope.nvim",
    tag = '0.1.4',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
      local builtin = require("telescope.builtin")
      vim.keymap.set('n', '<leader>fs', builtin.find_files, {})
      vim.keymap.set('n', '<leader>fc', builtin.live_grep, {})
      vim.keymap.set('n', '<leader>b', builtin.buffers, {})
      -- vim.keymap.set('n', '<leader>h', builtin.help_tags, {})
    end
  },
  {
    "folke/tokyonight.nvim",
    lazy = false,    -- make sure we load this during startup if it is your main colorscheme
    priority = 1000, -- make sure to load this before all the other start plugins
    config = function()
      -- load the colorscheme here
      vim.cmd([[colorscheme tokyonight]])
    end,
  },
  {
    'VonHeikemen/lsp-zero.nvim',
    branch = 'v3.x',
    config = function()
      local lsp_zero = require('lsp-zero')
      lsp_zero.extend_lspconfig()
      lsp_zero.on_attach(function(client, bufnr)
        lsp_zero.default_keymaps({ buffer = bufnr })
      end)
      local cmp = require('cmp')
      local cmp_action = require('lsp-zero').cmp_action()
      local cmp_autopairs = require('nvim-autopairs.completion.cmp')
      require('luasnip.loaders.from_vscode').lazy_load()
      cmp.setup({
        sources = {
          {name = 'nvim_lsp'},
          {name = 'luasnip'},
        },
        mapping = cmp.mapping.preset.insert({
          ['<Tab>'] = cmp_action.luasnip_supertab(),
          ['<S-Tab>'] = cmp_action.luasnip_shift_supertab(),
          ['<CR>'] = cmp.mapping.confirm({ select = false }),
        }),
        preselect = 'item',
        completion = {
          completeopt = 'menu,menuone,noinsert'
        }
      })
      cmp.event:on('confirm_done', cmp_autopairs.on_confirm_done())
      lsp_zero.format_on_save({
        format_opts = {
          async = false,
          timeout_ms = 10000,
        },
        servers = {
          ['null-ls'] = {"javascript", "javascriptreact", "typescript", "typescript.tsx", "typescriptreact"}
        }
      })
    end,
  },
  { 'neovim/nvim-lspconfig' },
  { 'hrsh7th/cmp-nvim-lsp' },
  { 'hrsh7th/nvim-cmp' },
  {
    'L3MON4D3/LuaSnip',
    dependencies = { "rafamadriz/friendly-snippets" },
  },
  {
    'williamboman/mason.nvim',
    config = function()
      require('mason').setup({})
    end
  },
  {
    'williamboman/mason-lspconfig.nvim',
    config = function()
      require('mason-lspconfig').setup({
        ensure_installed = { 'lua_ls', 'tsserver', 'biome', 'emmet_language_server' },
        handlers = {
          require('lsp-zero').default_setup
        },
      })
    end
  },
  { "windwp/nvim-ts-autotag" },
  {
    'numToStr/Comment.nvim',
    opts = {},
    lazy = false,
  },
  {
    'windwp/nvim-autopairs',
    event = "InsertEnter",
    opts = {} -- this is equalent to setup({}) function
  },
  {
    "nvimtools/none-ls.nvim",
    config = function()
      local null_ls = require("null-ls")
      null_ls.setup({
        sources = {
          null_ls.builtins.formatting.biome
        }
      })
    end
  },
  { "saadparwaiz1/cmp_luasnip" },
})

