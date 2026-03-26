host = "sleepless" -- TODO: move to nix

require("hyprland/animations")
require("hyprland/autostart")
require("hyprland/binds")
require("hyprland/functions")
require("hyprland/general")
require("hyprland/input")
require("hyprland/rules")
require("hyprland/workspaces")

hl.on("window.active", function(w)
  hl.dispatch(hl.exec_cmd("dunstify " .. w.class))
end)

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

    rounding = 14,
    rounding_power = 1.3 
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
