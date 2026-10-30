local M = {}

function M.config_home()
    return vim.fn.stdpath("cache") .. "/yazi-nvim-theme"
end

local function link_config(directory)
    local config_root = vim.env.XDG_CONFIG_HOME or (vim.env.HOME .. "/.config")
    local source = vim.env.YAZI_CONFIG_HOME or (config_root .. "/yazi")
    for _, name in ipairs({
        "yazi.toml",
        "keymap.toml",
        "vfs.toml",
        "init.lua",
        "plugins",
        "flavors",
        "package.toml",
    }) do
        local target = source .. "/" .. name
        local path = directory .. "/" .. name
        if vim.uv.fs_lstat(path) and vim.uv.fs_readlink(path) ~= target then
            assert(vim.uv.fs_unlink(path))
        end
        if vim.uv.fs_stat(target) then
            if not vim.uv.fs_lstat(path) then
                assert(vim.uv.fs_symlink(target, path))
            end
        elseif vim.uv.fs_lstat(path) then
            assert(vim.uv.fs_unlink(path))
        end
    end
end

local function highlight(name)
    local hl = vim.api.nvim_get_hl(0, { name = name, link = false })
    if hl.reverse then
        hl.fg, hl.bg = hl.bg, hl.fg
    end
    return hl
end

local function hex(color)
    return string.format("#%06x", color)
end

local function blend(bg, fg, amount)
    local color = 0
    for _, shift in ipairs({ 16, 8, 0 }) do
        local b = math.floor(bg / 2 ^ shift) % 256
        local f = math.floor(fg / 2 ^ shift) % 256
        color = color + math.floor(b + (f - b) * amount + 0.5) * 2 ^ shift
    end
    return color
end

local function palette()
    local normal = highlight("Normal")
    local dark = vim.o.background == "dark"
    local bg = normal.bg or (dark and 0x121212 or 0xf0f0f0)
    local fg = normal.fg or (dark and 0xc0c0c0 or 0x303030)
    local visual = highlight("Visual")
    local status = highlight("StatusLine")
    local colors = {
        bg = bg,
        fg = fg,
        surface = highlight("NormalFloat").bg or blend(bg, fg, 0.05),
        muted = highlight("Comment").fg or blend(bg, fg, 0.6),
        subtle = highlight("NonText").fg or blend(bg, fg, 0.35),
        border = highlight("WinSeparator").fg or blend(bg, fg, 0.25),
        selection_bg = visual.bg or blend(bg, fg, 0.18),
        selection_fg = visual.fg or fg,
        status_bg = status.bg or blend(bg, fg, 0.12),
        status_fg = status.fg or fg,
        accent = highlight("Directory").fg or fg,
        error = highlight("DiagnosticError").fg or fg,
        warning = highlight("DiagnosticWarn").fg or fg,
    }
    for key, value in pairs(colors) do
        colors[key] = hex(value)
    end
    return colors
end

local function write_theme()
    local colors = palette()
    local template = vim.fn.stdpath("config") .. "/yazi-theme.toml.in"
    local contents = table.concat(vim.fn.readfile(template), "\n")
    contents = contents:gsub("{{([%w_]+)}}", function(key)
        return assert(colors[key], "Unknown Yazi palette color: " .. key)
    end)

    local directory = M.config_home()
    vim.fn.mkdir(directory, "p")
    link_config(directory)
    local path = directory .. "/theme.toml"
    if vim.fn.filereadable(path) == 1 then
        if table.concat(vim.fn.readfile(path), "\n") == contents then
            return
        end
    end

    local temporary = path .. ".tmp." .. vim.fn.getpid()
    vim.fn.writefile(vim.split(contents, "\n", { plain = true }), temporary)
    local ok, err = vim.uv.fs_rename(temporary, path)
    if not ok then
        vim.fn.delete(temporary)
        error(err)
    end
end

function M.sync()
    local ok, err = pcall(write_theme)
    if not ok then
        vim.notify(
            "Could not sync Yazi theme: " .. tostring(err),
            vim.log.levels.WARN
        )
    end
    return ok
end

function M.setup()
    vim.api.nvim_create_autocmd("ColorScheme", {
        group = vim.api.nvim_create_augroup("YaziThemeSync", { clear = true }),
        desc = "Match Yazi to the active Neovim palette",
        callback = function()
            vim.schedule(M.sync)
        end,
    })
    vim.schedule(M.sync)
end

return M
