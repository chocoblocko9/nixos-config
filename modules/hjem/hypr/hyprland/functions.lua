local tracked = { firefox = 0, vesktop = 0 }

hl.on("window.active", function(w) 
  if (w.class == "vesktop") then 
    hl.window.alter_zorder({ window = "class:firefox", mode = "bottom" })()
  elseif (w.class == "firefox") then 
    hl.window.alter_zorder({ window = "class:vesktop", mode = "bottom" })()
  end
end)

hl.on("window.open", function(w)
  if (w.class == "firefox") then 
    tracked.firefox = tracked.firefox + 1
    if (tracked.firefox == 1) then 
      hl.window.tag({ window = "class:firefox", tag = "w1firefox" })()
    end
  elseif (w.class == "vesktop") then 
    tracked.vesktop = tracked.vesktop + 1
    if (tracked.vesktop == 1) then 
      hl.window.tag({ window = "class:vesktop", tag = "w1vesktop" })()
    end
  end
end)

hl.on("window.close", function(w) 
  if (w.class == "firefox") then 
    tracked.firefox = tracked.firefox - 1 
  elseif (w.class == "vesktop") then 
    tracked.vesktop = tracked.vesktop - 1 
  end
end)

function reset() 
  local ws = hl.get_windows()
  local f_target = { x = 444, y = 44, w = 1463, h = 1023 }
  local v_target = { x = 12 , y = 44, w = 1463, h = 1023 }

  for _, w in ipairs(ws) do 
    if w.tags[1] then 
      if (w.tags[1] == "w1firefox") then
        f_real = { x = w.at.x, y = w.at.y, w = w.size.x, h = w.size.y }
      elseif (w.tags[1] == "w1vesktop") then
        v_real = { x = w.at.x, y = w.at.y, w = w.size.x, h = w.size.y }
      end
    end
  end

  local function tables_equal(t1, t2)
    return t1.x == t2.x and t1.y == t2.y and t1.w == t2.w and t1.h == t2.h
  end
    
  if (tables_equal(f_real, f_target) and tables_equal(v_real, v_target)) then
    hl.window.move({ window = "class:firefox", x = 1468, y = 0 })()
    hl.window.move({ window = "class:vesktop", x = (-1468), y = 0 })()
  else 
    hl.window.move({ window = "class:firefox", x = (444 - f_real.x), y = (44 - f_real.y) })()
    hl.window.move({ window = "class:vesktop", x = (12 - v_real.x), y = (44 - v_real.y) })()
  end
end
