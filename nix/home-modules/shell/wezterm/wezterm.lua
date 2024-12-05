local wezterm = require 'wezterm'

local config = {
  audible_bell = "Disabled",

  color_scheme = 'ayu',
  font = wezterm.font('Source Code Pro'),
  font_size = 10.0,
  front_end = "WebGpu",

  initial_cols = 120,
  initial_rows = 30,

  hide_tab_bar_if_only_one_tab = true,

  enable_wayland = true,
  --dpi = 72,
}

return config
