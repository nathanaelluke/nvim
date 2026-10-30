local M = {}

function M.background()
    local normal = vim.api.nvim_get_hl(0, { name = "Normal", link = false })
    local color = normal.reverse and normal.fg or normal.bg
    if not color then
        return vim.o.background
    end
    local r = math.floor(color / 65536) % 256
    local g = math.floor(color / 256) % 256
    local b = color % 256
    return (0.2126 * r + 0.7152 * g + 0.0722 * b) >= 128 and "light" or "dark"
end

function M.list()
    local previous = {
        name = vim.g.colors_name or "default",
        background = vim.o.background,
        eventignore = vim.o.eventignore,
        lazyredraw = vim.o.lazyredraw,
    }
    local themes = {}
    vim.o.eventignore = "all"
    vim.o.lazyredraw = true
    local ok, err = pcall(function()
        for _, name in ipairs(vim.fn.getcompletion("", "color")) do
            for _, background in ipairs({ "dark", "light" }) do
                vim.g.colors_name = nil
                vim.o.background = background
                local loaded = pcall(vim.cmd.colorscheme, name)
                if loaded and M.background() == background then
                    themes[#themes + 1] = {
                        name = name,
                        background = background,
                    }
                end
            end
        end
    end)

    vim.g.colors_name = nil
    vim.o.background = previous.background
    local restored, restore_error = pcall(vim.cmd.colorscheme, previous.name)
    vim.o.eventignore = previous.eventignore
    vim.o.lazyredraw = previous.lazyredraw
    if not restored then
        error(restore_error)
    end
    vim.api.nvim_exec_autocmds("ColorScheme", { pattern = previous.name })
    if not ok then
        error(err)
    end
    return themes
end

return M
