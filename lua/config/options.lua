vim.g.mapleader = " "
vim.g.maplocalleader = "\\"
vim.opt.clipboard = "unnamedplus"
vim.cmd("set termguicolors")
vim.cmd("set number")
vim.cmd.colorscheme("moon")
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    local arg = vim.fn.argv(0)
    if arg ~= "" and vim.fn.isdirectory(arg) == 1 then
      require("telescope.builtin").find_files({ cwd = arg })
    end
  end,
})
vim.opt.undofile = true
vim.opt.undodir = vim.fn.stdpath("data") .. "/undo"
vim.opt.expandtab = true      -- use spaces instead of tabs
vim.opt.shiftwidth = 2        -- indentation size
vim.opt.tabstop = 2           -- visual width of tabs
vim.opt.softtabstop = 2       -- spaces per tab while editing
vim.opt.smartindent = true    -- auto-indent new lines
vim.opt.autoindent = true
vim.opt.breakindent = true    -- wrapped lines keep indentation
vim.lsp.config('*', {
  capabilities = {
    textDocument = {
      semanticTokens = {
        multilineTokenSupport = true,
      }
    }
  },
  root_markers = { '.git' },
})
vim.lsp.config('clangd', {
  filetypes = { 'c', 'cpp', 'h', 'hpp' },
})
vim.lsp.enable('clangd')
vim.cmd("syntax enable")
vim.opt.conceallevel = 1
vim.keymap.set("v", ">", ">gv", { noremap = true, desc = "Indent right and reselect" })
vim.keymap.set("v", "<", "<gv", { noremap = true, desc = "Indent left and reselect" })
vim.diagnostic.config({
    virtual_text = true,
})
local opts = { noremap=true, silent=true }

local function quickfix()
    vim.lsp.buf.code_action({
        filter = function(a) return a.isPreferred end,
        apply = true
    })
end

