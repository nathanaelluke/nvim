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

local theme_file = vim.fn.stdpath("data") .. "/current_theme.txt"

vim.keymap.set("n", "<leader>th", function()
  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")

  require("telescope.builtin").colorscheme({
    enable_preview = true,
    ignore_builtins = true,
    
    -- This hooks into the picker to run our custom save logic
    attach_mappings = function(prompt_bufnr, map)
      actions.select_default:replace(function()
        -- Get the theme the user hit Enter on
        local selection = action_state.get_selected_entry()
        actions.close(prompt_bufnr)

        if selection then
          local theme_name = selection.value
          
          vim.cmd.colorscheme(theme_name)

          local f = io.open(theme_file, "w")
          if f then
            f:write(theme_name)
            f:close()
            vim.notify("Default theme updated to: " .. theme_name, vim.log.levels.INFO)
          end
        end
      end)
      return true
    end,
  })
end, { desc = "Telescope: Theme Selector (Persistent)" })
