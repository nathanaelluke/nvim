local function setup_directory_startup()
    vim.api.nvim_create_autocmd("VimEnter", {
        callback = function()
            local arg = vim.fn.argv(0)
            if arg ~= "" and vim.fn.isdirectory(arg) == 1 then
                require("telescope.builtin").find_files({ cwd = arg })
            end
        end,
    })
end

local function setup_theme_picker_command()
    local theme_file = vim.fn.stdpath("data") .. "/current_theme.txt"

    vim.api.nvim_create_user_command("TelescopeThemePicker", function()
        local actions = require("telescope.actions")
        local action_state = require("telescope.actions.state")

        require("telescope.builtin").colorscheme({
            enable_preview = true,
            ignore_builtins = true,

            attach_mappings = function(prompt_bufnr, map)
                actions.select_default:replace(function()
                    local selection = action_state.get_selected_entry()
                    actions.close(prompt_bufnr)

                    if selection then
                        local theme_name = selection.value
                        vim.cmd.colorscheme(theme_name)

                        local f = io.open(theme_file, "w")
                        if f then
                            f:write(theme_name)
                            f:close()
                            vim.notify(
                                "Default theme updated to: " .. theme_name,
                                vim.log.levels.INFO
                            )
                        end
                    end
                end)
                return true
            end,
        })
    end, {})
end

return {
    "nvim-telescope/telescope.nvim",
    tag = "v0.1.6",
    config = function()
        local actions = require("telescope.actions")

        require("telescope").setup({
            defaults = {
                borderchars = {
                    "─",
                    "│",
                    "─",
                    "│",
                    "┌",
                    "┐",
                    "┘",
                    "└",
                },
                layout_strategy = "horizontal",
                previewer = true,
                layout_config = {
                    horizontal = { width = 0.95 },
                    preview_cutoff = 0,
                    preview_width = 0.5,
                },
                mappings = {
                    n = {
                        q = actions.close,
                    },
                },
            },
            pickers = {
                buffers = {
                    show_all_buffers = true,
                    sort_last_used = true,
                    previewer = true,
                    mappings = {
                        i = {
                            ["<c-d>"] = "delete_buffer",
                        },
                    },
                },
            },
        })

        setup_directory_startup()
        setup_theme_picker_command()
    end,
}
