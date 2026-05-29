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
    ui = {
      enable = true,
      hl_groups = {
        ObsidianRefText = { underline = true, fg = "#666666" },
        ObsidianExtLinkIcon = { fg = "#666666" },
      },
    },
  },
}
