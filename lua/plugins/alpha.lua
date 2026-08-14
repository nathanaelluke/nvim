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

        local function in_vault_cwd()
            local cwd = vim.fs.normalize(vim.fn.getcwd())
            return cwd == vault_root or vim.startswith(cwd, vault_root .. "/")
        end

        local function set_header(lines)
            dashboard.section.header.val = lines
        end

        local function set_buttons(buttons)
            dashboard.section.buttons.val = buttons
        end

        local function find_buf_by_name(path)
            for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
                if vim.api.nvim_buf_get_name(bufnr) == path then
                    return bufnr
                end
            end
        end

        local function open_blank_note_buffer(path, write_now)
            local bufnr = find_buf_by_name(path)
            if bufnr then
                vim.api.nvim_set_current_buf(bufnr)
            else
                vim.cmd("enew")
                bufnr = vim.api.nvim_get_current_buf()
                vim.api.nvim_buf_set_name(bufnr, path)
                vim.bo[bufnr].filetype = "markdown"
            end

            vim.bo[bufnr].buftype = ""
            vim.bo[bufnr].bufhidden = ""
            vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { "" })

            if write_now then
                vim.cmd("write!")
            end
        end

        local function normalize_note_name(input)
            local value = (input or "")
                :gsub("[/\\]", "-")
                :gsub("[%c]", "")
                :gsub("^%s+", "")
                :gsub("%s+$", "")

            if value == "" then
                value = tostring(os.time())
            end

            return value
        end

        vim.api.nvim_create_user_command("VaultNewNote", function()
            vim.ui.input({ prompt = "New note title: " }, function(input)
                if input == nil then
                    return
                end

                vim.fn.mkdir(notes_dir, "p")
                local path = string.format(
                    "%s/%s.md",
                    notes_dir,
                    normalize_note_name(input)
                )
                local should_overwrite = vim.uv.fs_stat(path) ~= nil

                local function continue_open(overwrite)
                    open_blank_note_buffer(path, overwrite)
                end

                if should_overwrite then
                    vim.ui.select({ "No", "Yes" }, {
                        prompt = string.format(
                            "Overwrite existing note '%s'?",
                            vim.fs.basename(path)
                        ),
                    }, function(choice)
                        if choice == "Yes" then
                            continue_open(true)
                        end
                    end)
                else
                    continue_open(false)
                end
            end)
        end, {})

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
                dashboard.button("y", "  > browse files", ":Yazi<CR>"),
                dashboard.button(
                    "f",
                    "  > find file",
                    ":Telescope find_files<CR>"
                ),
                dashboard.button(
                    "g",
                    "  > find text",
                    ":Telescope live_grep<CR>"
                ),
                dashboard.button("r", "  > recent", ":Telescope oldfiles<CR>"),
                dashboard.button("z", "  > quit", ":q<CR>"),
            })
        end

        local function make_vault_dashboard()
            set_header({
                [[                   ]],
                [[   ▄▖▌   ▘ ▌▘  ▘   ]],
                [[   ▌▌▛▌▛▘▌▛▌▌▌▌▌▛▛▌]],
                [[   ▙▌▙▌▄▌▌▙▌▌▚▘▌▌▌▌]],
            })

            set_buttons({
                dashboard.button(
                    "h",
                    "  > home",
                    string.format(":edit %s<CR>", vim.fn.fnameescape(home_note))
                ),
                dashboard.button("n", "  > new note", ":VaultNewNote<CR>"),
                dashboard.button(
                    "y",
                    "  > browse vault",
                    string.format(
                        ":cd %s | Yazi<CR>",
                        vim.fn.fnameescape(vault_root)
                    )
                ),
                dashboard.button("z", "  > quit", ":q<CR>"),
            })
        end

        vim.api.nvim_create_user_command("VaultDashboard", function()
            make_vault_dashboard()
            alpha.setup(dashboard.opts)
            vim.cmd.Alpha()
        end, {})

        -- Remove end-of-buffer filler lines when alpha is open
        vim.api.nvim_create_autocmd("FileType", {
            pattern = "alpha",
            callback = function()
                vim.opt_local.fillchars:append({ eob = " " })
            end,
        })

        if in_vault_cwd() then
            make_vault_dashboard()
        else
            make_default_dashboard()
        end

        alpha.setup(dashboard.opts)
    end,
}
