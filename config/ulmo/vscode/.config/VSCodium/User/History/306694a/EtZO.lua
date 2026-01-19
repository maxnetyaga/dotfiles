-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This will hold the configuration.
local config = wezterm.config_builder()

config.default_prog = {"wsl.exe", "-d", "Arch", "--cd", "~"}

-- This is where you actually apply your config choices.

-- For example, changing the initial geometry for new windows:
config.initial_cols = 120
config.initial_rows = 28

-- or, changing the font size and color scheme.
config.font_size = 12
config.color_scheme = 'OneHalfDark'

config.font = wezterm.font_with_fallback {'ComicShannsMono Nerd Font Mono', 'Consolas'}

config.enable_tab_bar = false

config.front_end = "OpenGL"

-- Finally, return the configuration to wezterm:
return config