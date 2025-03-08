return {
	{"gbprod/nord.nvim",
				lazy = false,
				priority = 1000,
				config = function()
          vim.cmd([[colorscheme nord]])
				end,
  },
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      -- your configuration comes here
      -- or leave it empty to use the default settings
      -- refer to the configuration section below
    },
    keys = {
      {
        "<leader>?",
        function()
          require("which-key").show({ global = false })
        end,
        desc = "Buffer Local Keymaps (which-key)",
      },
    },
  },
  {
    'nvim-telescope/telescope.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' }
  },
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = true
  },
  {
    "nvim-tree/nvim-tree.lua",
    version = "*",
    lazy = false,
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
    config = function()
      -- nvim-tree config
      require("nvim-tree").setup({
        sync_root_with_cwd = true,   
        respect_buf_cwd = true,      
        view = {
          preserve_window_proportions = true,
        },
        actions = {
          open_file = {
            resize_window = true,
          },
        },
      })
      
      -- Autocmd to keep nvim-tree open across tabs
      vim.api.nvim_create_autocmd("TabEnter", {
        callback = function()
          local api = require("nvim-tree.api")
          if not api.tree.is_visible() then
            api.tree.open()
          end
        end,
      })
    end,
  }
}
