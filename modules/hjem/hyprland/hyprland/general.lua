local mon_scale = 1 
if (host == "sleepless") then
  mon_scale = 1.2
end

hl.monitor({
  output = "",
  mode = "preferred",
  position = "auto",
  scale = mon_scale,
})
