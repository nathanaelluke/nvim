return {
  "aznhe21/actions-preview.nvim",
  dependencies = {
    "nvim-telescope/telescope.nvim",
  },
  event = "LspAttach",
  keys = {
    {
      "<leader>ca",
      function()
        require("actions-preview").code_actions()
      end,
      mode = { "n", "v" },
      desc = "Code Actions Preview",
    },
  },
  opts = {
    backend = { "telescope" },

    telescope = {
      layout_strategy = "vertical",
      layout_config = {
        height = 0.75,
        prompt_position = "top",
        preview_cutoff = 40,
      },
      borderchars = {
        "─", "│", "─", "│",
        "┌", "┐", "┘", "└",
      },
    },

    highlight_command = {
      function()
        return require("actions-preview.highlight").delta()
      end,
    },
  },
}
