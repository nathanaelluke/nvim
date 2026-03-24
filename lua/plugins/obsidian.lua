return {
  {
    "epwalsh/obsidian.nvim",
    version = "*",
    lazy = true,
    ft = "markdown",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {
      workspaces = {
        {
          name = "Vault",
          path = "/home/nathanael/GitHub/Vault/",
        },
      },
      completion = {
        nvim_cmp = true,
      },

      ui = {
        enable = false,
      },

      note_frontmatter_func = function(_)
        return {}
      end,
    },
  },
}
