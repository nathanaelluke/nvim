return {
  {
    "casedami/neomodern.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("neomodern").setup({
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
      })
      require("neomodern").load()
    end,
  },
}
