return {
    "goolord/alpha-nvim",
    dependencies = {
        "echasnovski/mini.icons",
    },

    config = function()
        local alpha = require("alpha")
        local dashboard = require("alpha.themes.dashboard")
        local vault_root = vim.fs.normalize("/home/nathanael/github/vault")
        local home_note = vault_root .. "/home.md"
        local notes_dir = vault_root .. "/notes"

        local function set_header(lines)
            dashboard.section.header.val = lines
        end

        local function set_buttons(buttons)
            dashboard.section.buttons.val = buttons
        end

        local function make_default_dashboard()
            set_header({
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
            })

            set_buttons({
                dashboard.button("<leader>y", "  > yazi", ":Yazi<CR>"),
                dashboard.button(
                    "<leader>ff",
                    "  > find file",
                    ":Telescope find_files<CR>"
                ),
                dashboard.button(
                    "<leader>fw",
                    "  > find text",
                    ":Telescope live_grep<CR>"
                ),
                dashboard.button("ZZ", "  > quit", ":q<CR>"),
            })
        end

        vim.api.nvim_create_autocmd("FileType", {
            pattern = "alpha",
            callback = function()
                -- Keep Alpha's default wipe behavior so its resize handler is removed.
                vim.opt_local.fillchars:append({ eob = " " })
            end,
        })

        make_default_dashboard()

        alpha.setup(dashboard.opts)
    end,
}
