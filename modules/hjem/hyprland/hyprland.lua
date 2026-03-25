host = "sleepless" -- TODO: move to nix

require("hyprland/binds")

hl.config({
  general = {
    gaps_in = 5,
    gaps_out = 5,10,10,10,

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
    rounding_power = 2
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

hl.monitor({
  output = "",
  mode = "preferred",
  position = "auto",
  scale = 1.2,
})

require("hyprland/autostart")
