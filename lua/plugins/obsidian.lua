return {
  "epwalsh/obsidian.nvim",
  version = "*",
  lazy = true,
  event = {
      "BufReadPre /home/nathanael/github/vault/*.md",
      "BufNewFile /home/nathanael/github/vault/*.md",
  },
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  opts = {
    workspaces = {
      {
        name = "vault",
        path = "/home/nathanael/github/vault/",
      },
    },

  },
}
