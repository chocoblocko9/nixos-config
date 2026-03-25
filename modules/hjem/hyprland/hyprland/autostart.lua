-- Stupid ass hack to implement exec-once lmao
-- TODO: Replace with exec-once when implemented
STARTUP = STARTUP or false

hl.on("workspace.active", function(ws)
  if not STARTUP then
    -- Launch apps
    io.popen("hyprpaper &")
    io.popen("hyprsunset &")
    io.popen("firefox &")
    io.popen("kitty --class kitty-nvim --config ~/.files/modules/hjem/kitty/nvim.conf nvim &")
    
    STARTUP = true
  end
end)
