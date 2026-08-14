vim.lsp.config("clangd", {
    filetypes = { "c", "cpp", "h", "hpp" },
    root_markers = { ".clangd", ".clang-tidy", ".clang-format" },
    cmd = { "clangd", "--background-index" },
})

vim.lsp.config("lua_ls", {
    cmd = { "lua-language-server" },
    filetypes = { "lua" },
    root_markers = {
        ".luarc.json",
        ".luacheckrc",
        ".stylua.toml",
        "stylua.toml",
        ".git",
    },
    settings = {
        Lua = {
            diagnostics = {
                globals = { "vim" },
            },
            workspace = {
                library = vim.api.nvim_get_runtime_file("", true),
                checkThirdParty = false,
            },
        },
    },
})

vim.api.nvim_create_autocmd("VimEnter", {
    callback = function()
        vim.lsp.enable("clangd")
        vim.lsp.enable("lua_ls")
    end,
})

vim.diagnostic.config({
    signs = false,
    underline = true,
    virtual_text = false,
})
