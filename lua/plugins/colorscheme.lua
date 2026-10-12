local function terminal_send(sequence)
    if vim.env.TMUX then
        sequence = "\027Ptmux;" .. sequence:gsub("\027", "\027\027") .. "\027\\"
    end
    vim.api.nvim_ui_send(sequence)
end

local function sync_terminal_background()
    local normal = vim.api.nvim_get_hl(0, { name = "Normal", link = false })
    if normal.bg then
        terminal_send(string.format("\027]11;#%06x\007", normal.bg))
    else
        terminal_send("\027]111\007")
    end
end

local function load_saved_colorscheme()
    local theme_file = vim.fn.stdpath("data") .. "/current_theme.txt"
    local f = io.open(theme_file, "r")
    local theme_to_load = "gyokuro"

    if f then
        local saved_theme = f:read("*l")
        local saved_background = f:read("*l")
        f:close()
        if saved_theme and saved_theme ~= "" then
            theme_to_load = saved_theme
            if saved_background == "dark" or saved_background == "light" then
                vim.o.background = saved_background
            end
        end
    end

    pcall(vim.cmd.colorscheme, theme_to_load)
end

local function setup_colorscheme_autocmds()
    vim.api.nvim_create_autocmd("ColorScheme", {
        callback = function()
            vim.api.nvim_set_hl(0, "DiagnosticUnderlineError", {
                undercurl = true,
                sp = "#ff0000",
            })

            vim.api.nvim_set_hl(0, "FloatBorder", {
                fg = "#ffffff",
            })

            sync_terminal_background()
        end,
    })

    vim.api.nvim_create_autocmd("VimLeavePre", {
        callback = function()
            terminal_send("\027]111\007")
        end,
    })
end

setup_colorscheme_autocmds()

vim.api.nvim_create_autocmd("VimEnter", {
    callback = function()
        load_saved_colorscheme()
        sync_terminal_background()
    end,
    nested = true,
})

return {
    {
        "casedami/neomodern.nvim",
        commit = "d414695",
        lazy = false,
        priority = 1000,
        config = function()
            require("neomodern").setup({
                bg = "default",
                theme = "moon",
                overrides = {},
            })
        end,
    },
    {
        "oskarnurm/koda.nvim",
        version = "v2.11.0",
        lazy = false,
        priority = 1000,
    },
    {
        "vague2k/vague.nvim",
        lazy = false,
        priority = 1000,
        config = function()
            require("vague").setup({})
        end,
    },
    {
        "mellow-theme/mellow.nvim",
        lazy = false,
        priority = 1000,
    },
}
