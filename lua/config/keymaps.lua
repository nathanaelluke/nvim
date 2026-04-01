local map = vim.keymap.set

local function load_plugin(plugin)
  local ok, lazy = pcall(require, "lazy")
  if ok then
    lazy.load({ plugins = { plugin } })
  end
end

-- Find files
map('n', '<leader>ff', require('telescope.builtin').find_files, { desc = "Find Files" })

-- Live grep
map('n', '<leader>fg', require('telescope.builtin').live_grep, { desc = "Live Grep" })

-- Buffers
map('n', '<leader>fb', require('telescope.builtin').buffers, { desc = "Buffers" })

-- Help tags
map('n', '<leader>fh', require('telescope.builtin').help_tags, { desc = "Help Tags" })

vim.keymap.del("n", "<C-l>")

vim.keymap.set("n", "<leader>w", function()
  require("which-key").show({ keys = "<leader>" })
end, { desc = "Which-Key" })

vim.keymap.set("v", ">", ">gv", { noremap = true, desc = "Indent right and reselect" })
vim.keymap.set("v", "<", "<gv", { noremap = true, desc = "Indent left and reselect" })

map("n", "<leader>?", function()
  load_plugin("which-key.nvim")
  require("which-key").show({ global = false })
end, { desc = "Buffer Local Keymaps" })

map("n", "<leader>gg", "<cmd>Neogit<cr>", { desc = "Show Neogit UI" })

map({ "n", "v" }, "<leader>ca", function()
  load_plugin("actions-preview.nvim")
  require("actions-preview").code_actions()
end, { desc = "Code Actions Preview" })

map("n", "<leader>y", "<cmd>Yazi<cr>", { desc = "Open yazi at the current file" })
map("n", "<leader>cw", "<cmd>Yazi cwd<cr>", { desc = "Open the file manager in nvim's working directory" })
map("n", "<C-Up>", "<cmd>Yazi toggle<cr>", { desc = "Resume the last yazi session" })

map("n", "<M-a>", function()
  load_plugin("harpoon")
  require("harpoon"):list():add()
end, { desc = "Harpoon add file" })

map("n", "<C-e>", function()
  load_plugin("harpoon")
  local harpoon = require("harpoon")
  local list = harpoon:list()
  harpoon.ui:toggle_quick_menu(list)
end, { desc = "Harpoon menu" })

map("n", "<M-1>", function()
  load_plugin("harpoon")
  require("harpoon"):list():select(1)
end, { desc = "Harpoon select file 1" })

map("n", "<M-2>", function()
  load_plugin("harpoon")
  require("harpoon"):list():select(2)
end, { desc = "Harpoon select file 2" })

map("n", "<M-3>", function()
  load_plugin("harpoon")
  require("harpoon"):list():select(3)
end, { desc = "Harpoon select file 3" })

map("n", "<M-4>", function()
  load_plugin("harpoon")
  require("harpoon"):list():select(4)
end, { desc = "Harpoon select file 4" })

map("n", "<M-h>", function()
  load_plugin("harpoon")
  require("harpoon"):list():prev()
end, { desc = "Harpoon previous file" })

map("n", "<M-l>", function()
  load_plugin("harpoon")
  require("harpoon"):list():next()
end, { desc = "Harpoon next file" })
