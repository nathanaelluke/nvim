return {
  "goolord/alpha-nvim",
  dependencies = {
    "echasnovski/mini.icons",
  },

  config = function()
    local alpha = require("alpha")
    local dashboard = require("alpha.themes.dashboard")

    -- Remove end-of-buffer filler lines when alpha is open
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "alpha",
      callback = function()
        vim.opt_local.fillchars:append({ eob = " " })
      end,
    })

    dashboard.section.header.val = {
      [[     _____                           ]],
      [[    |A .  | _____                    ]],
      [[    | /.\ ||A ^  | _____             ]],
      [[    |(_._)|| / \ ||A _  | _____      ]],
      [[    |  |  || \ / || ( ) ||A_ _ |     ]],
      [[    |____V||  .  ||(_'_)||( v )|     ]],
      [[           |____V||  |  || \ / |     ]],
      [[                  |____V||  .  |     ]],
      [[                         |____V|     ]],
      [[                                     ]],
    }

    dashboard.section.buttons.val = {
      dashboard.button("b", "  > browse files", ":Yazi<CR>"),
      dashboard.button("f", "  > find file", ":Telescope find_files<CR>"),
      dashboard.button("g", "  > find text", ":Telescope live_grep<CR>"),
      dashboard.button("r", "  > recent", ":Telescope oldfiles<CR>"),
      dashboard.button("z", "  > quit", ":q<CR>"),
    }

    alpha.setup(dashboard.opts)
  end,
}
