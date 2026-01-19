return {
    {
        "jesseleite/nvim-macroni",
        lazy = false,
        opts = {
            macros = {
                wrap_into_frame = {
                    macro = "ddPVr<C-V><Ignore>u2550I<C-V>u2554<Esc>A<C-V>u2557<Esc>pA<C-V>u2551<Esc>I<C-V>u2551<Esc>kyyjpI<Right><BS><C-V>u255a<Esc>A<BS><C-V>u255a<BS><C-V>u255d<Esc>",
                },
                insert_frame = {
                    macro = "o<C-V>u2554<Esc>78A<C-V>u2550<Esc>A<C-V>u2557<Esc>yypI<Right><BS><C-V>u255a<Esc>A<BS><C-V>u255d<Esc>O<C-V>u2551<Esc>78A<Space><Esc>A<C-V>u2551<Esc>",
                },
            },
        },
    },
}
