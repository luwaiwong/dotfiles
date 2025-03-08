require("config.lazy")

-- Setting tab settings
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.autoindent = true
vim.opt.smarttab = true

-- HOTKEYS
vim.g.mapleader = " "

vim.keymap.set("n", "<C-z>", "u", { noremap = true, silent = true })  -- Undo in normal mode
vim.keymap.set("i", "<C-z>", "<C-o>u", { noremap = true, silent = true })  -- Undo in insert mode
vim.keymap.set("v", "<C-z>", "u", { noremap = true, silent = true })  -- Undo in visual mode

-- Telescope
local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Telescope find files' })
vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Telescope live grep' })
vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Telescope buffers' })
vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Telescope help tags' })

-- Which Key
vim.keymap.set('n', '<C-h>', ':WhichKey<CR>') 

-- Nvim Tree
vim.keymap.set('n','<leader>tf',':NvimTreeToggle<CR>')
vim.keymap.set('n','<leader>to',':NvimTreeOpen<CR>')
vim.keymap.set('n','<leader>tc',':NvimTreeClose<CR>')
-- vim.keymap.set('n', '<leader>tf', ':NvimTreeFindFile<CR>')
vim.keymap.set('n', '<leader>tr', ':NvimTreeReload<CR>')


-- Settings
-- Load the nord color scheme
require('nord')

-- Customize the tab colors

-- Active tab color (foreground and background)
vim.api.nvim_set_hl(0, 'TabLineSel', { fg = '#ECEFF4', bg = '#5e81ac'})  -- Light text and blue background for active tab

-- Inactive tab color
vim.api.nvim_set_hl(0, 'TabLine', { fg = '#4C566A', bg = '#2e3440' })  -- Darker gray for inactive tabs

-- Tabline background color
vim.api.nvim_set_hl(0, 'TabLineFill', { fg = '#D8DEE9', bg = '#2E3440' })  -- Lighter background for the tabline

