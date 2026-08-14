local function load_saved_colorscheme()
    local theme_file = vim.fn.stdpath("data") .. "/current_theme.txt"
    local f = io.open(theme_file, "r")
    local theme_to_load = "gyokuro"

    if f then
        local saved_theme = f:read("*l")
        f:close()
        if saved_theme and saved_theme ~= "" then
            theme_to_load = saved_theme
        end
    end

    pcall(vim.cmd.colorscheme, theme_to_load)
end

local function setup_colorscheme_autocmds()
    local light_background_themes = {
        roseprime = true,
    }

    vim.api.nvim_create_autocmd("ColorScheme", {
        callback = function()
            local name = vim.g.colors_name
            if light_background_themes[name] then
                vim.o.background = "light"
            else
                vim.o.background = "dark"
            end

            vim.api.nvim_set_hl(0, "DianosticUnderlineError", {
                undercurl = true,
                sp = "#ff0000",
            })

            vim.api.nvim_set_hl(0, "FloatBorder", {
                fg = "#ffffff",
            })
        end,
    })
end

setup_colorscheme_autocmds()

vim.api.nvim_create_autocmd("VimEnter", {
    callback = function()
        load_saved_colorscheme()
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
                gutter = { cursorline = false, dark = false },
                diagnostics = {
                    darker = true,
                    undercurl = true,
                    background = true,
                },
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
