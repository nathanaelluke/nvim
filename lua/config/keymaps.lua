local map = vim.keymap.set

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
