-- Full config reference: https://wezfurlong.org/wezterm/config/lua/config
local wezterm = require 'wezterm'

local config = wezterm.config_builder()

-- Appearance 
config.window_background_opacity = 1
config.macos_window_background_blur = 20
config.hide_tab_bar_if_only_one_tab = true

-- Window
config.adjust_window_size_when_changing_font_size = false
config.window_padding = {
  left = 4,
  right = 4,
  top = 0,
  bottom = 0,
}

return config
