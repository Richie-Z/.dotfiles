local c = require("assets.mocha")

local function rgba(hex, alpha)
	return "rgba(" .. hex .. (alpha or "ff") .. ")"
end

hl.config({
	general = {
		gaps_in = 5,
		gaps_out = { top = 8, right = 8, bottom = 8, left = 8 },
		border_size = 1,
		col = {
			active_border = { colors = { rgba(c.mauve, "ee"), rgba(c.blue, "ee") }, angle = 90 },
			inactive_border = rgba(c.mantle, "aa"),
		},
		resize_on_border = true,
		allow_tearing = false,
	},
	group = {
		col = {
			border_active = rgba(c.blue),
		},
		groupbar = {
			col = {
				active = rgba(c.blue),
			},
			font_family = "Geist",
			font_size = 12,
			indicator_gap = 8,
		},
	},
	decoration = {
		rounding = 10,
		rounding_power = 2,
		active_opacity = 1.0,
		inactive_opacity = 0.9,
		fullscreen_opacity = 1.0,
		dim_inactive = true,
		dim_strength = 0.2,
		blur = {
			enabled = true,
			size = 5,
			passes = 1,
			ignore_opacity = true,
			xray = true,
		},
		shadow = {
			enabled = true,
			range = 32,
			render_power = 2,
			color = rgba(c.surface1, "2e"),
			color_inactive = rgba(c.surface0, "00"),
		},
	},
})

-- Smart gaps: a single tiled window fills the workspace.
hl.workspace_rule({
	workspace = "w[tv1]",
	gaps_out  = 0,
	gaps_in   = 0,
})

-- Picture-in-picture floats, pins and keeps a sane size.
hl.window_rule({
	name   = "picture-in-picture",
	match  = { title = "Picture-in-Picture" },
	float  = true,
	pin    = true,
	size   = { 480, 270 },
	center = true,
})
