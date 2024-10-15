local wezterm = require 'wezterm'

local config = {
  audible_bell = "Disabled",

  color_scheme = 'ayu',
  font = wezterm.font('Source Code Pro'),
  front_end = "WebGpu",

  enable_wayland = false,
  dpi = 72,
}

return config
