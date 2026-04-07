hl.exec_once("hyprpaper & hyprsunset & soteria & lollypop")
hl.exec_once("firefox")
hl.exec_once("qs")
hl.exec_once("kitty --class kitty-nvim --config ~/.files/modules/hjem/kitty/nvim.conf nvim &")

if (host == "slip") then
  hl.exec_once("vesktop")
  hl.exec_once("mprisence & nicotine -s & mpris-scrobbler")
  hl.exec_once("sleep 5; hyprctl --batch 'dispatch tagwindow +firefox class:firefox; dispatch tagwindow +vesktop class:vesktop'")
end
--[[
exec-once=[workspace 1; float; size 1463 1023; move 444 44] firefox
exec-once=bash ~/.files/modules/hjem/hyprland/scripts/raiseonhover.sh
exec-once=sleep 5; hyprctl --batch 'dispatch tagwindow +firefox class:firefox; dispatch tagwindow +vesktop class:vesktop'
]]
