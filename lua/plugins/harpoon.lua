return {
  "ThePrimeagen/harpoon",
  branch = "harpoon2",
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  config = function()
    local harpoon = require("harpoon")

    harpoon:setup({
      menu = {
        border = { "┌", "─", "┐", "│", "┘", "─", "└", "│" },
      },
    })

    local list = harpoon:list()

    -- Add file
    vim.keymap.set("n", "<M-a>", function()
      list:add()
    end, { desc = "Harpoon add file" })

    -- Toggle menu
    vim.keymap.set("n", "<C-e>", function()
      harpoon.ui:toggle_quick_menu(list)
    end, { desc = "Harpoon menu" })

    -- Direct access (Alt + number)
    vim.keymap.set("n", "<M-1>", function() list:select(1) end, { desc = "Harpoon select file 1" })
    vim.keymap.set("n", "<M-2>", function() list:select(2) end, { desc = "Harpoon select file 2" })
    vim.keymap.set("n", "<M-3>", function() list:select(3) end, { desc = "Harpoon select file 3" })
    vim.keymap.set("n", "<M-4>", function() list:select(4) end, { desc = "Harpoon select file 4" })

    -- Cycling (Alt + h/l)
    vim.keymap.set("n", "<M-h>", function() list:prev() end, { desc = "Harpoon previous file" })
    vim.keymap.set("n", "<M-l>", function() list:next() end, { desc = "Harpoon next file" })
  end,
}
