-- Curves
for _, p in ipairs { 
  { "linear",               "bezier", 0,    1,    1,    1     },
  { "easeInOutBack",        "bezier", 0.68, -0.6, 0.32, 1.6   },
  { "easeInOutSine",        "bezier", 0.37, 0,    0.63, 1     },
  { "easeInExpo",           "bezier", 0.7,  0,    0.84, 0     },
  { "easeOutQuart",         "bezier", 0.25, 1,    0.5,  1     },
  { "easeOutExpo",          "bezier", 0.16, 1,    0.3,  1     },
  { "easeOutExpoOvershoot", "bezier", 0.16, 1,    0.3,  1.05  },
  { "easeOutCirc",          "bezier", 0.85, 0,    0.15, 1     },
  { "bouncyThing",          "bezier", 0.15, 0.60, 0.66, -0.61 },
} do 
  hl.curve(p[1], { type = p[2], points = { {p[3],p[4]}, {p[5],p[6]} } })
end

-- Animtions
for _, p in ipairs { 
  { "windowsIn",           true, 2.5, "easeOutExpo",          "popin"         },
  { "windowsOut",          true, 4,   "easeOutExpo",          "popin 10%"     },
  { "windowsMove",         true, 0.9, "easeOutExpo",          ""              },
  { "workspaces",          true, 1.4, "easeInOutSine",        "slidefade 50%" },
  { "specialWorkspaceIn",  true, 2.8, "easeOutExpoOvershoot", "slide top"     },
  { "specialWorkspaceOut", true, 5,   "easeInOutBack",        "slide bottom"  },
} do 
  hl.animation { leaf = p[1], enabled = p[2], speed = p[3], bezier = p[4], style = p[5] } 
end

hl.config({
  animations = {
    enabled = true,
    workspace_wraparound = true,
  },
})


