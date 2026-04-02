hl.on("window.active", function(w) 
  if (w.class == "vesktop") then 
    hl.window.alter_zorder({ window = "class:firefox", mode = "bottom" })()
  elseif (w.class == "firefox") then 
    hl.window.alter_zorder({ window = "class:vesktop", mode = "bottom" })()
  end
end)
