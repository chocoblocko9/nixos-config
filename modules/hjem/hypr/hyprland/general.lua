local mon_scale = 1 
if (host == "sleepless") then
  mon_scale = 1.2
end

hl.config({
  general = {
    gaps_in = 1,
    gaps_out = {
      top = 4,
      bottom = 5,
      right = 5,
      left = 5,
    },

    border_size = 3,
    col = {
      active_border = "rgb(0f5570)",
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
    rounding_power = 1.3,

    blur = { special = true },
    shadow = { enabled = false },
  },

  render = { direct_scanout = 2 },

  --[[
  debug = {
    disable_logs = false,
    enable_stdout_logs = true,
  },
  ]]
})

hl.monitor({
  output = "",
  mode = "preferred",
  position = "auto",
  scale = mon_scale,
})
