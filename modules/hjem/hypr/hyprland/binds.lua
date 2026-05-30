----  VAR  ----
local term = "kitty"
local fm = "thunar"
local menu = "fuzzel"

---- BINDS ----

-- Normal binds
hl.bind("SUPER + Q", hl.dsp.exec_cmd(term))
hl.bind("SUPER + Return", hl.dsp.exec_cmd(term))
hl.bind("SUPER + C", hl.dsp.window.close())
hl.bind("SUPER + F", hl.dsp.exec_cmd("firefox"))
hl.bind("SUPER + M", hl.dsp.exit())
hl.bind("SUPER + E", hl.dsp.exec_cmd(fm))
hl.bind("SUPER + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind("SUPER + D", hl.dsp.exec_cmd(menu))
hl.bind("SUPER + P", hl.dsp.window.pseudo())
hl.bind("SUPER + J", hl.dsp.layout("togglesplit"))

hl.bind("SUPER + R", reset)

-- bind=$mod, B, exec, bash ~/.files/modules/hjem/hyprland/scripts/minimisetospecial.sh
hl.bind("SUPER + B", function() -- TODO: Implement above function
  hl.dispatch(hl.exec_cmd("kitty"))
end)

hl.bind("SUPER + mouse:272", hl.dsp.window.drag(),  { mouse = true })
hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Move focus
for _, pair in ipairs({ {"left","l"}, {"right","r"}, {"up","u"}, {"down","d"} }) do
    hl.bind("SUPER + " .. pair[1], hl.dsp.focus({ direction = pair[2] }))
end

-- Workspace switching
for i = 1, 10 do
    local key = tostring(i % 10)
    hl.bind("SUPER + "         .. key, hl.dsp.focus({ workspace = i }) )
    hl.bind("SUPER + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }) )
end

-- Mouse binds
hl.bind("SUPER + mouse_up", hl.dsp.focus({ workspace = "r-1" }) )
hl.bind("SUPER + mouse_down", hl.dsp.focus({ workspace = "r+1" }) )
hl.bind("SUPER + mouse_right", hl.dsp.layout("cyclenext"))
hl.bind("SUPER + mouse_left", hl.dsp.layout("cycleprev"))
hl.bind("SUPER + mouse:272", hl.dsp.window.drag(),  { mouse = true })
hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Screenshots
hl.bind("Print", hl.dsp.exec_cmd('grim -g "$(slurp -d)" - | wl-copy'))

-- Music special workspace
hl.bind("SUPER + S"        , hl.dsp.workspace.toggle_special("music"))
hl.bind("SUPER + SHIFT + S", hl.dsp.window.move({ workspace = "special:music"}))

-- F1-F12 binds 
if (host == "slip") then
  hl.bind("SUPER + F3", hl.dsp.exec_cmd("ddcutil --sleep-multiplier .1 --bus=8 setvcp 10 + 10", { locked = true, repeating = true }))
  hl.bind("SUPER + F2", hl.dsp.exec_cmd("ddcutil --sleep-multiplier .1 --bus=8 setvcp 10 - 10", { locked = true, repeating = true }))
elseif (host == "sleepless") then
  hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl -q -n s +10%", { locked = true, repeating = true }))
  hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -q -n s 10%-", { locked = true, repeating = true }))
end

hl.bind("SUPER + SUPER_L", hl.dsp.exec_cmd("pkill fuzzel || fuzzel"))
-- Music player & audio
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 10%+", { locked = true, repeating = true }))
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 10%-", { locked = true, repeating = true }))
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle", { locked = true }))

for _, pair in ipairs({ {"Next","next"}, {"Prev","previous"}, {"Play","play-pause"}, {"Stop","stop"} }) do
    hl.bind("XF86Audio" .. pair[1], hl.dsp.exec_cmd("playerctl --player=Lollypop " .. pair[2], { locked = true } ))
end
 
-- TODO: port to hyprctl eval
hl.bind("SUPER + Z", function()
  hl.config({ cursor = { zoom_factor = 2 }})
end)
-- hl.bind("SUPER + Z", hl.exec_cmd("hyprctl eval 'hl.config({ cursor = { zoom_factor = 2.5 }})' && hyprctl reload"))
hl.bind("SUPER + X", hl.dsp.exec_cmd("hyprctl eval 'hl.config({ cursor = { zoom_factor = 1 }})' && hyprctl reload", { release = true }))

------ CONFIG ------
hl.config({
  binds = {
    scroll_event_delay = 50,
  },
})
