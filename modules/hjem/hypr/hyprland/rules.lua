------  VARIABLES  ------

local def_float = {
  "Open.*",
  "File Upload.*",
  "Select what to share",
  "Volume Control",
  "File Operation Progress",
}

------ WINDOW RULES ------
hl.window_rule({ workspace = "2 silent", match = { class = "kitty-nvim" } })
hl.window_rule({ opacity = "0.97, 0.75", match = { class = "negative:kitty" } })

if (host == "slip") then
  hl.window_rule {
    name = "vesktop behaviour",
    float = true,
    match = { class = "vesktop", workspace = 1 },
    move = "12 44",
    size = "1463 1023",
    suppress_event = "maximize"
  }

  hl.window_rule {
    name = "firefox behaviour",
    float = true,
    match = { class = "firefox", workspace = 1 },
    move = "444 44",
    size = "1463 1023",
  }
end
  
for _, t in ipairs(def_float) do 
  hl.window_rule {
    float = true,
    match = { title = t },
    size = "(monitor_w*0.75) (monitor_h*0.75)",
  }
end

hl.window_rule {
  float = true,
  match = { class = "lollypop" },
  size = "(monitor_w*0.9) (monitor_h*0.9)",
  workspace = "special:music silent",
}

hl.window_rule {
  name = "Fix GD Fullscreen",
  match = { title = "Geometry Dash" },
  fullscreen_state = "2 0",
  content = "game"
  -- Launch Options: WINEDLLOVERRIDES="xinput1_4=n,b" gamescope -r 75 -f -w 1920 -h 1080 -- %command%
}

hl.window_rule {
  name  = "fix-xwayland-drags",
  no_focus = true,
  match = {
      class      = "^$",
      title      = "^$",
      xwayland   = true,
      float      = true,
      fullscreen = false,
      pin        = false,
  },
}

------ LAYER RULES ------

hl.layer_rule({ 
  name = "screenshot fix",
  no_anim = true, 
  match = { namespace = "selector" },
})

hl.layer_rule({ blur = true, match = { namespace = "quickshell" } })
