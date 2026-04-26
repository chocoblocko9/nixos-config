hl.on("window.active", function(w) 
  if (w.class == "vesktop") then 
    hl.dsp.window.alter_zorder({ window = "class:firefox", mode = "bottom" })()
  elseif (w.class == "firefox") then 
    hl.dsp.window.alter_zorder({ window = "class:vesktop", mode = "bottom" })()
  end
end)

-- Tags the window it with the respective tag if it's the first one opened
hl.on("window.open", function(w)
  if w.class == "firefox" then 
    local firefoxes = hl.get_windows({ class = "firefox" })
    if #firefoxes == 1 then
      hl.dsp.window.tag({ window = "class:firefox", tag = "w1firefox" })()
    end
  elseif w.class == "vesktop" then 
    local vesktops = hl.get_windows({ class = "vesktop" })
    if #vesktops == 1 then
      hl.dsp.window.tag({ window = "class:vesktop", tag = "w1vesktop" })()
    end
  end
end)

-- Resets windows if they've moved/changed size, otherwise slides them to the side
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
    hl.dsp.window.move({ window = "class:firefox", x = 1480, y = -540, relative = true })()
    hl.dsp.window.move({ window = "class:vesktop", x = -1480, y = 540, relative = true })()
  else 
    hl.dsp.window.move({ window = "class:firefox", x = 444, y = 44 })()
    hl.dsp.window.move({ window = "class:vesktop", x = 12, y = 44 })()
  end
end
