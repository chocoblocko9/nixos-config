host = "slip" -- TODO: move to nix

require("hyprland/animations")
require("hyprland/autostart")
require("hyprland/binds")
require("hyprland/functions")
require("hyprland/general")
require("hyprland/input")
require("hyprland/rules")
require("hyprland/workspaces")

hl.on("window.active", function(w)
  if (w.class == "vesktop") then 
    -- hl.dispatch(hl.exec_cmd("dunstify " .. w.class))
    -- hl.dispatch(hl.exec_cmd("hyprctl dispatch alterzorder bottom, class:firefox"))
  elseif (w.class == "firefox") then
    -- hl.dispatch(hl.exec_cmd("dunstify " .. w.class))
    -- hl.dispatch(hl.exec_cmd("hyprctl dispatch alterzorder bottom, class:vesktop"))
  end
end)
