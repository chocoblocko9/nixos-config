------ WORKSPACE RULES ------
hl.workspace_rule({ workspace = 3, persistent = true })
hl.workspace_rule({ workspace = 4, persistent = true, layout = "monocle" })
hl.workspace_rule({ workspace = 5, persistent = true, layout = "scrolling" })
hl.workspace_rule({ workspace = 9, persistent = true, no_rounding = false, border_size = 2 })

------ LAYOUT ------
hl.config({
  dwindle = {
    pseudotile = true,
    smart_split = true,
    preserve_split = true,
  },
})

hl.config({
  decoration = {
    blur = {
     special = true
    },
  },
})
