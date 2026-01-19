return {
    {
        "mistricky/codesnap.nvim",
        build = "make",
        opts = {
            mac_window_bar = false,
            title = "CodeSnap.nvim",
            code_font_family = "ComicCodeLigatures Nerd Font Mono",
            watermark_font_family = "Pacifico",
            watermark = "",
            bg_theme = "default",
            breadcrumbs_separator = "/",
            has_breadcrumbs = true,
            has_line_number = true,
            show_workspace = false,
            min_width = 0,
            bg_x_padding = 122,
            bg_y_padding = 82,
            save_path = os.getenv("XDG_PICTURES_DIR") or (os.getenv("HOME") .. "/Pictures")
        }
    },
}
