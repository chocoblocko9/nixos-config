----  VAR  ----
local MOD = "SUPER"

local term = "kitty"
local fm = "thunar"
local mp = "lollypop"
local menu = "fuzzel"
local repeats = { ["repeat"] = true }

---- BINDS ----

-- Normal binds
hl.bind(MOD, "Q", hl.exec_cmd(term))
hl.bind(MOD, "C", hl.window.close()) -- TODO: Steam script?
hl.bind(MOD, "F", hl.exec_cmd("firefox"))
hl.bind(MOD, "M", hl.exec_cmd("hyprctl dispatch exit")) -- TODO: hyprshutdown?
hl.bind(MOD, "E", hl.exec_cmd(fm))
hl.bind(MOD, "V", hl.window.toggle_float())
hl.bind(MOD, "D", hl.exec_cmd(menu))
hl.bind(MOD, "P", hl.window.pseudo())
hl.bind(MOD, "J", hl.layout("togglesplit")) -- report: kinda inconsistent naming

-- bind=$mod, R, exec, bash ~/.files/modules/hjem/hyprland/scripts/reset.sh
hl.bind(MOD, "R", function() -- TODO: Implement above function
end)

-- bind=$mod, B, exec, bash ~/.files/modules/hjem/hyprland/scripts/minimisetospecial.sh
hl.bind(MOD, "B", function() -- TODO: Implement above function
end)

hl.bind(MOD, "mouse:272", hl.window.drag(),  { mouse = true })
hl.bind(MOD, "mouse:273", hl.window.resize(), { mouse = true })
hl.bind(MOD, "K", function()
    hl.dispatch(hl.exec_cmd("kitty"))
end)

-- Move focus
for _, pair in ipairs({ {"left","l"}, {"right","r"}, {"up","u"}, {"down","d"} }) do
    hl.bind(MOD, pair[1], hl.focus.direction(pair[2]))
end

for i = 1, 10 do
    local key = tostring(i % 10)
    hl.bind(MOD,              key, hl.workspace.go(i))
    hl.bind(MOD .. "SHIFT",  key, hl.workspace.move_window(i))
end

-- Mouse binds
hl.bind(MOD, "mouse_up",   hl.workspace.go("e-1"))
hl.bind(MOD, "mouse_down", hl.workspace.go("e+1"))
hl.bind(MOD, "mouse_right", hl.layout("cyclenext"))
hl.bind(MOD, "mouse_left", hl.layout("cycleprev"))
hl.bind(MOD, "mouse:272", hl.window.drag(),  { mouse = true })
hl.bind(MOD, "mouse:273", hl.window.resize(), { mouse = true })

-- Screenshots
hl.bind("", "Print", hl.exec_cmd('grim -g "$(slurp -d)" - | wl-copy'))

-- Music special workspace
hl.bind(MOD, "S", hl.workspace.special("music"))
hl.bind(MOD .. "SHIFT", "S", hl.workspace.move_window("special:music"))

-- F1-F12 binds 
if (host == "slip") then
  hl.bind(MOD, "F3", hl.exec_cmd("ddcutil --sleep-multiplier .1 --bus=8 setvcp 10 + 10", { locked = true, ["repeat"] = true }))
  hl.bind(MOD, "F2", hl.exec_cmd("ddcutil --sleep-multiplier .1 --bus=8 setvcp 10 - 10", { locked = true, ["repeat"] = true }))
elseif (host == "sleepless") then
  hl.bind("", "XF86MonBrightnessUp",   hl.exec_cmd("brightnessctl -q -n s +10%", { locked = true, ["repeat"] = true }))
  hl.bind("", "XF86MonBrightnessDown", hl.exec_cmd("brightnessctl -q -n s 10%-", { locked = true, ["repeat"] = true }))
end

hl.bind("", "XF86AudioRaiseVolume", hl.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 10%+", { locked = true, ["repeat"] = true }))
hl.bind("", "XF86AudioLowerVolume", hl.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 10%-", { locked = true, ["repeat"] = true }))
hl.bind("", "XF86AudioNext", hl.exec_cmd("playerctl --player=Lollypop next", { locked = true }))
hl.bind("", "XF86AudioPrev", hl.exec_cmd("playerctl --player=Lollypop previous", { locked = true }))
hl.bind("", "XF86AudioPlay", hl.exec_cmd("playerctl --player=Lollypop play-pause", { locked = true }))
hl.bind("", "XF86AudioStop", hl.exec_cmd("playerctl --player=Lollypop stop", { locked = true }))
hl.bind("", "XF86AudioMute", hl.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle", { locked = true }))

-- TODO: port to hyprctl eval
hl.bind(MOD, "Z", hl.exec_cmd("hyprctl eval 'hl.config({ cursor = { zoom_factor = 2.5 }})' && hyprctl reload"))
hl.bind(MOD, "X", hl.exec_cmd("hyprctl eval 'hl.config({ cursor = { zoom_factor = 1 }})' && hyprctl reload", { release = true }))
--[[
# F1-F12 binds
# Zoom thing
bindl=$mod, Z, exec,hyprctl keyword cursor:zoom_factor 2.5
bindrl=$mod, Z, exec,hyprctl keyword cursor:zoom_factor 1

binds {
  scroll_event_delay=50
}
--]]
