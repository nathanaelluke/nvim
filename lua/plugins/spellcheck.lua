return {
    "preservim/vim-lexical",
    ft = "markdown",

    config = function()
        local spell_dir = vim.fn.stdpath("config") .. "/spell"
        vim.fn.mkdir(spell_dir, "p")

        local function enable_spell()
            vim.fn["lexical#init"]({
                spell = 1,
                spelllang = { "en_us" },
                spellfile = {
                    spell_dir .. "/en.utf-8.add",
                },
            })
        end

        vim.api.nvim_create_autocmd("FileType", {
            pattern = "markdown",
            callback = enable_spell,
        })

        if vim.bo.filetype == "markdown" then
            enable_spell()
        end
    end,
}
