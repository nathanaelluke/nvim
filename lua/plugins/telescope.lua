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
        local conf = require("telescope.config").values
        local before_theme = vim.g.colors_name or "default"
        local before_background = vim.o.background
        local selected = false
        local variants = require("config.theme_variants")
        local active_background = variants.background()
        local themes = variants.list()
        local default_selection_index = 1

        for index, theme in ipairs(themes) do
            if
                theme.name == before_theme
                and theme.background == active_background
            then
                default_selection_index = index
                break
            end
        end

        local function apply_theme(theme)
            vim.g.colors_name = nil
            vim.o.background = theme.background
            local ok, err = pcall(vim.cmd.colorscheme, theme.name)
            if not ok then
                vim.notify(err, vim.log.levels.ERROR)
            end
            return ok
        end

        local bufnr = vim.api.nvim_get_current_buf()
        local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
        local filetype = vim.bo[bufnr].filetype
        local picker = require("telescope.pickers").new({}, {
            prompt_title = "Change Colorscheme",
            finder = require("telescope.finders").new_table({
                results = themes,
                entry_maker = function(theme)
                    local label = theme.name .. " (" .. theme.background .. ")"
                    return { value = theme, display = label, ordinal = label }
                end,
            }),
            sorter = conf.generic_sorter({}),
            default_selection_index = default_selection_index,
            previewer = require("telescope.previewers").new_buffer_previewer({
                define_preview = function(self)
                    vim.api.nvim_buf_set_lines(
                        self.state.bufnr,
                        0,
                        -1,
                        false,
                        lines
                    )
                    vim.bo[self.state.bufnr].filetype = filetype
                end,
            }),
            attach_mappings = function(prompt_bufnr)
                actions.select_default:replace(function()
                    local selection = action_state.get_selected_entry()
                    if not selection or not apply_theme(selection.value) then
                        return
                    end

                    selected = true
                    actions.close(prompt_bufnr)
                    local theme = selection.value
                    local f, err = io.open(theme_file, "w")
                    if f then
                        f:write(theme.name .. "\n" .. vim.o.background .. "\n")
                        f:close()
                        vim.notify(
                            "Default theme updated to: " .. selection.display,
                            vim.log.levels.INFO
                        )
                    else
                        vim.notify(
                            "Could not save theme: " .. err,
                            vim.log.levels.ERROR
                        )
                    end
                end)
                return true
            end,
        })

        local close_windows = picker.close_windows
        picker.close_windows = function(status)
            close_windows(status)
            if not selected then
                apply_theme({
                    name = before_theme,
                    background = before_background,
                })
            end
        end

        local set_selection = picker.set_selection
        picker.set_selection = function(self, row)
            set_selection(self, row)
            local selection = self:get_selection()
            if selection then
                apply_theme(selection.value)
            end
        end

        picker:find()
    end, {})
end

return {
    "nvim-telescope/telescope.nvim",
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
