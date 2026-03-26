host = "slip" -- TODO: move to nix

require("hyprland/autostart")
require("hyprland/binds")
require("hyprland/general")

hl.window_rule({
  match = { class = ".*" }, 
  rounding_power = 1.2,
  rounding = 15,
})

hl.config({
  general = {
    gaps_in = 5,
    gaps_out = {
      top = 5,
      bottom = 10,
      right = 10,
      left = 10,
    },

    border_size = 3,
    col = {
      active_border = "rgb(2A7B9B)",
      inactive_border = "rgb(072242)",
    },

    resize_on_border = true,
    allow_tearing = false,
    layout = "dwindle",
  },

  decoration = {
    dim_inactive = true,
    dim_strength = 0.35,
    dim_special = 0.6,

    rounding = 8,
  },
  input = {
    kb_layout = "eu",
    kb_options = "ctrl:swapcaps",
    follow_mouse = 1,
    repeat_delay = 300,
    repeat_rate = 40,
  },

  dwindle = {
    pseudotile = true,
    smart_split = true,
    preserve_split = true,
  },

  debug = {
    disable_logs = false,
    enable_stdout_logs = true,
  },
})
