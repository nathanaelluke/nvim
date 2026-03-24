return {
  {
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-mini/mini.nvim",
    },
    opts = {
      preset = "obsidian",
      heading = {
        sign = false,
        position = "inline",
        width = "block",
        border = false,
        border_virtual = false,
        left_pad = 1,
        right_pad = 1,
      },
    },
  },
}
