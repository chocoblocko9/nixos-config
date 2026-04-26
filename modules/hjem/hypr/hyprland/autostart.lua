hl.exec_once("hyprpaper & hyprsunset & soteria & lollypop")
hl.exec_once("firefox")
hl.exec_once("qs")
hl.exec_once("kitty --class kitty-nvim --config ~/.files/modules/hjem/kitty/nvim.conf nvim &")

if (host == "subvert") then 
  hl.exec_once("pipewire & pipewire-pulse & wireplumber")
  hl.exec_once("xdg-desktop-portal-hyprland")
end

if (host ~= "sleepless") then
  hl.exec_once("vesktop")
  hl.exec_once("mprisence & nicotine -s & mpris-scrobbler")
end
