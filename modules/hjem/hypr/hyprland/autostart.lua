hl.on("hyprland.start", function()
  hl.exec_cmd("hyprpaper & hyprsunset & soteria & lollypop")
  hl.exec_cmd("firefox")
  hl.exec_cmd("qs")
  hl.exec_cmd("kitty --class kitty-nvim --config ~/.files/modules/hjem/kitty/nvim.conf nvim &")

  if (host == "subvert") then 
    hl.exec_cmd("pipewire & pipewire-pulse & wireplumber")
    hl.exec_cmd(xdph .. "/libexec/xdg-desktop-portal-hyprland")
  end

  if (host ~= "sleepless") then
    hl.exec_cmd("vesktop")
    hl.exec_cmd("mprisence & nicotine -s & mpris-scrobbler")
  end
end)

-- Kill pipewire so it doesn't duplicate and break on restart of hyprland
hl.on("hyprland.shutdown", function()
  if (host == "subvert") then
    hl.exec_cmd("pkill pipewire")
  end
end)
