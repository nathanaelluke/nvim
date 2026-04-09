return {
  {
    "casedami/neomodern.nvim",
    lazy = true,
    priority = 1000,
    opts = {
      bg = "default",
      theme = "moon",
      gutter = {
        cursorline = false,
        dark = false,
      },
      diagnostics = {
        darker = true,
        undercurl = true,
        background = true,
      },
      overrides = {},
    },
    config = function(_, opts)
      require("neomodern").setup(opts)
    end,
  },
  {
    "vague-theme/vague.nvim",
    lazy = false,
    priority = 1000,
    opts = {},
    config = function(_, opts)
      require("vague").setup(opts)
    end,
  },
}
