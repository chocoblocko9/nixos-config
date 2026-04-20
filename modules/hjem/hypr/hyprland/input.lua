hl.config({
  input = {
    kb_layout = "eu",
    kb_options = "ctrl:swapcaps",
    follow_mouse = 1,
    repeat_delay = 300,
    repeat_rate = 40,
  },
})

hl.gesture({
  fingers = 3,
  direction = "horizontal",
  action = "workspace",
})

hl.gesture({
  fingers = 3,
  direction = "up",
  action = "close"
})

-- gesture = 3, swipe, mod: ALT, resize TODO: port to lua
