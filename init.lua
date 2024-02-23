local opt = vim.opt
local g = vim.g
local map = vim.api.nvim_set_keymap

-- normal neovim options

-- shows number on the left
opt.number = true
opt.termguicolors = true
-- tabs uses 4 spaces
opt.tabstop = 4
opt.shiftwidth = 4

opt.expandtab = true
opt.lazyredraw = true

g.do_filetype_lua = true
g.did_load_filetypes = false

map('n', 'cf', 'gg=G<CR>', {})

-- plugins

-- bootstrapping, don't touch
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
require('lazy').setup({

  'folke/lazy.nvim', -- keep

    -- auto save plugin
  {
    'Pocco81/auto-save.nvim',
    config = function()
      require('auto-save').setup()
    end,
    event = 'VeryLazy',
  },
    -- syntax highlight
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    config = function ()
      require('nvim-treesitter.configs').setup({
        auto_install = true,
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = false
        },
        indent = {
          enable = true
        }
      })
    end,
    event = 'VeryLazy'
  },
    -- catppuccin color scheme
  {
    'catppuccin/nvim',
    name = 'catppuccin',
    priority = 1000,
    lazy = false,
    config = function ()
      require('catppuccin').setup({
        transparent_background = true,
        term_colors = true,
        no_italic = true
      })
      vim.cmd.colorscheme('catppuccin')
    end,
    build = ':CatppuccinCompile',
  },
    -- the bar on top
  {
    'romgrk/barbar.nvim',
    dependencies = {
      'nvim-web-devicons',
      'catppuccin'
    },
    event = 'VeryLazy'
  },
    -- telescope plugin
  {
    'nvim-telescope/telescope.nvim',
    dependencies = 'nvim-lua/plenary.nvim',
    cmd = 'Telescope',
    init = function()
      vim.api.nvim_set_keymap('n', 'tt', ':Telescope<CR>', {})
    end
  },
    -- file explorer plugin
  {
    'nvim-tree/nvim-tree.lua',
    dependencies = 'nvim-web-devicons',
    config = function()
      require('nvim-tree').setup()
    end,
    cmd = 'NvimTreeToggle',
    init = function()
      vim.api.nvim_set_keymap('n', 'ff', ':NvimTreeToggle<CR>', {})
    end
  },
    -- the line at the bottom
  {
    'nvim-lualine/lualine.nvim',
    dependencies = {
      'nvim-tree/nvim-web-devicons',
      'catppuccin'
    },
    config = function()
      require('lualine').setup()
    end,
    event = 'VeryLazy'
  },
    -- allow icons
  {
    'nvim-tree/nvim-web-devicons',
    lazy = true
  },
    -- auto add pairs of (), [], {}, "", ''
  {
    "windwp/nvim-autopairs",
    config = function()
      require("nvim-autopairs").setup({})
    end,
    event = 'InsertEnter'
  },
    -- auto completion
  {
    'hrsh7th/nvim-cmp',
    dependencies = {
      'dcampos/nvim-snippy',
      'dcampos/cmp-snippy',
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-cmdline',
      'onsails/lspkind.nvim',
      'williamboman/mason-lspconfig.nvim'
    },
    event = {
      'InsertEnter',
      'CmdlineEnter'
    },
    config = function()
      local cmp = require('cmp')
      local map = cmp.mapping
      local compare = require('cmp.config.compare')

      cmp.setup({
        formatting = {
          format = require('lspkind').cmp_format({
            mode = 'symbol',
            maxwidth = 50,
            ellipsis_char = '...'
          })
        },

        snippet = {
          expand = function(args)
            require('snippy').expand_snippet(args.body)
          end
        },
        matching = {
          disallow_fuzzying_matching = false,
          disallow_partial_fuzzying_matching = false,
          disallow_partial_matching = false,
          disallow_prefix_unmatching = false
        },
        sorting = {
          priority_weight = 2.0,
          comparators = {
            compare.locality,
            compare.recently_used,
            compare.score,
            compare.offset
          }
        },
        mapping = {
          ['<UP>'] = map(map.select_prev_item(), {'i', 's', 'c'}),
          ['<Down>'] = map(map.select_next_item(), {'i', 's', 'c'}),
          ['<M-Enter>'] = map(map.abort(), {'i', 's', 'c'}),
          ["<Enter>"] = map(function(fallback)
            -- enter selected completion
            if cmp.visible() then
              local entry = cmp.get_selected_entry()
              if entry then
                cmp.confirm()
              end
            else
              fallback()
            end
          end, {'i','s','c'}),
        },
        sources = cmp.config.sources({
          { name = 'nvim_lsp' },
          { name = 'snippy' }
        },
          {
            { name = 'buffer' }
          })
      })
      cmp.setup.cmdline({ '/', '?' }, {
        mapping = map.preset.cmdline(),
        sources = {
          { name = 'buffer' }
        }
      })
    end
  },
    -- provides auto complete
  {
    'williamboman/mason-lspconfig.nvim',
    dependencies = {
      'neovim/nvim-lspconfig',
      'williamboman/mason.nvim',
    },
    build = ':MasonUpdate',
    init = function()
      require('mason').setup()

      require('mason-lspconfig').setup({
        automatic_installation = {
          exclude = {}
        }
      })

      local lsp = require('lspconfig')
      local capabilities = require('cmp_nvim_lsp').default_capabilities()
      local function setup(server)
        lsp[server].setup({
          capabilities = capabilities
        })
      end
      require('mason-lspconfig').setup_handlers({
        setup
      })
    end
  },
})
