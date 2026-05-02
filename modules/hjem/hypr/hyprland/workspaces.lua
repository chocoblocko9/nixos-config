------ WORKSPACE RULES ------
hl.workspace_rule({ workspace = 3, persistent = true })
hl.workspace_rule({ workspace = 6, persistent = true, layout = "monocle" })
hl.workspace_rule({ workspace = 7, persistent = true, layout = "scrolling" })
hl.workspace_rule({ workspace = 9, persistent = true, no_rounding = false, border_size = 2 })

------ LAYOUT ------
hl.config({
  dwindle = {
    smart_split = true,
    preserve_split = true,
  },
})
