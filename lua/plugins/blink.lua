return {
    "saghen/blink.cmp",
    dependencies = {
        "rafamadriz/friendly-snippets",
        "ribru17/blink-cmp-spell",
    },

    version = "1.*",
    opts = {
        keymap = {
            preset = "enter",
        },
        appearance = {
            nerd_font_variant = "mono",
        },

        completion = { documentation = { auto_show = false } },

        sources = {
            default = { "lsp", "path", "snippets", "buffer" },
            per_filetype = {
                markdown = { inherit_defaults = true, "spell" },
            },
            providers = {
                spell = {
                    name = "Spell",
                    module = "blink-cmp-spell",
                    opts = {
                        preselect_current_word = false,
                        use_cmp_spell_sorting = true,
                    },
                },
            },
        },

        fuzzy = { implementation = "prefer_rust_with_warning" },
    },
    opts_extend = { "sources.default" },
}
