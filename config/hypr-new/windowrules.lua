hl.window_rule({
	name = "suppress-maximize-events",
	match = {
		class = ".*",
	},
	-- Ignore maximize requests from all apps. You'll probably like this.
	suppress_event = "maximize",
})

hl.window_rule({
	name = "fix-xwayland-drags",
	match = {
		class = "^$",
		title = "^$",
		xwayland = true,
		float = true,
		fullscreen = false,
		pin = false,
	},
	-- Fix some dragging issues with XWayland
	no_focus = true,
})

-- Hyprland-run windowrule
hl.window_rule({
	name = "move-hyprland-run",
	match = {
		class = "hyprland-run",
	},
	move = "20 monitor_h-120",
	float = true,
})

hl.window_rule({
	match = {
		class = "^(com.saivert.pwvucontrol)$",
	},
	float = true,
})
