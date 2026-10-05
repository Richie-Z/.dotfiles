local c = require("assets.mocha")

local function rgba(hex, alpha)
	return "rgba(" .. hex .. (alpha or "ff") .. ")"
end

hl.config({
	general = {
		gaps_in = 6,
		gaps_out = { top = 10, right = 10, bottom = 10, left = 10 },
		border_size = 2,
		col = {
			-- rosewater -> mauve -> blue, diagonal. Catppuccin Mocha only.
			active_border = {
				colors = { rgba(c.rosewater, "ee"), rgba(c.mauve, "ff"), rgba(c.blue, "ee") },
				angle = 135,
			},
			inactive_border = { colors = { rgba(c.surface0, "cc"), rgba(c.mantle, "99") }, angle = 135 },
		},
		resize_on_border = true,
		allow_tearing = false,
	},
	group = {
		col = {
			border_active = { colors = { rgba(c.mauve, "ff"), rgba(c.pink, "ff") }, angle = 135 },
			border_inactive = rgba(c.surface0, "aa"),
		},
		groupbar = {
			col = {
				active = { colors = { rgba(c.peach, "ff"), rgba(c.mauve, "ff") }, angle = 90 },
				inactive = { colors = { rgba(c.surface0, "cc"), rgba(c.mantle, "cc") }, angle = 90 },
				locked_active = rgba(c.peach, "ff"),
			},
			text_color = rgba(c.subtext0),
			font_family = "Geist",
			font_size = 13,
			height = 16,
			rounding = 5,
			indicator_gap = 6,
		},
	},
	decoration = {
		rounding = 14,
		rounding_power = 2,
		active_opacity = 1.0,
		inactive_opacity = 0.92,
		fullscreen_opacity = 1.0,
		dim_inactive = true,
		dim_strength = 0.2,
		blur = {
			enabled = true,
			size = 7,
			passes = 2,
			ignore_opacity = true,
			xray = true,
			new_optimizations = true,
			vibrancy = 0.17,
		},
		shadow = {
			enabled = true,
			range = 45,
			render_power = 3,
			offset = { 0, 6 },
			scale = 1.0,
			color = rgba(c.mauve, "33"),
			color_inactive = rgba(c.blue, "1a"),
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
