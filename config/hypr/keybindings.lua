-- Keybindings. Structure is data-driven; behaviour is identical to the old
-- .conf config except for two binds whose dispatchers do not exist in 0.56:
-- workspaceopt allfloat and changegroupactive (both dropped).

local mainMod = "SUPER"
local HOME = os.getenv("HOME")
local waybar = HOME .. "/.config/waybar"
local scripts = HOME .. "/.config/hypr/scripts"

local terminal    = "kitty"
local browser     = "zen-browser"
local fileManager = "dolphin"
local menu        = "hyprlauncher"

local bind = hl.bind
local dsp  = hl.dsp

-- Directional aliases: arrows and vim keys drive the same dispatchers.
local DIRECTIONS = { "left", "right", "up", "down" }
local VIM_KEY    = { left = "H", right = "L", down = "J", up = "K" }
local SWAP_DIR   = { left = "l", right = "r", up = "u", down = "d" }
local RESIZE_BY  = { left = { -50, 0 }, right = { 50, 0 }, up = { 0, -50 }, down = { 0, 50 } }

for _, d in ipairs(DIRECTIONS) do
	local delta = RESIZE_BY[d]
	bind(mainMod .. " + " .. d, dsp.focus({ direction = d }))
	bind(mainMod .. " + " .. VIM_KEY[d], dsp.focus({ direction = d }))
	bind(mainMod .. " + SHIFT + " .. d, dsp.window.resize({ x = delta[1], y = delta[2], relative = true }), { repeating = true })
	bind(mainMod .. " + ALT + " .. d, dsp.window.swap({ direction = SWAP_DIR[d] }))
	bind(mainMod .. " + ALT + " .. VIM_KEY[d], dsp.window.swap({ direction = SWAP_DIR[d] }))
end

-- Window control
bind(mainMod .. " + Q", dsp.window.close())
bind(mainMod .. " + SHIFT + Q", dsp.window.kill())
bind(mainMod .. " + F", dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" }))
bind(mainMod .. " + M", dsp.window.fullscreen({ mode = "maximized", action = "toggle" }))
bind(mainMod .. " + T", dsp.window.float({ action = "toggle" }))
bind("ALT + Tab", dsp.window.cycle_next({ next = true }))

-- Move and resize with the mouse
bind(mainMod .. " + mouse:272", dsp.window.drag(), { mouse = true })
bind(mainMod .. " + mouse:273", dsp.window.resize(), { mouse = true })

-- Layout
bind(mainMod .. " + SHIFT + J", dsp.layout("togglesplit"))
bind(mainMod .. " + SHIFT + K", dsp.layout("togglesplit"))
bind(mainMod .. " + SHIFT + H", dsp.layout("swapsplit"))
bind(mainMod .. " + SHIFT + L", dsp.layout("swapsplit"))

-- Groups
bind(mainMod .. " + G", dsp.group.toggle())

-- Workspaces
for i = 1, 10 do
	local key = i % 10
	bind(mainMod .. " + " .. key, dsp.focus({ workspace = i }))
	bind(mainMod .. " + SHIFT + " .. key, dsp.window.move({ workspace = i }))
	bind(mainMod .. " + CTRL + " .. key, dsp.window.move({ workspace = i, follow = false }))
end

bind(mainMod .. " + SHIFT + bracketleft", dsp.window.move({ workspace = -1 }))
bind(mainMod .. " + SHIFT + bracketright", dsp.window.move({ workspace = "+1" }))
bind(mainMod .. " + CTRL + bracketleft", dsp.window.move({ workspace = -1, follow = false }))
bind(mainMod .. " + CTRL + bracketright", dsp.window.move({ workspace = "+1", follow = false }))

bind(mainMod .. " + Tab", dsp.focus({ workspace = "m+1" }))
bind(mainMod .. " + SHIFT + Tab", dsp.focus({ workspace = "m-1" }))
bind(mainMod .. " + mouse_down", dsp.focus({ workspace = "e+1" }))
bind(mainMod .. " + mouse_up", dsp.focus({ workspace = "e-1" }))
bind(mainMod .. " + CTRL + down", dsp.focus({ workspace = "empty" }))

-- Special workspace
bind(mainMod .. " + SHIFT + U", dsp.window.move({ workspace = "special" }))
bind(mainMod .. " + U", dsp.workspace.toggle_special(""))

-- Cursor zoom. State lives in Lua so the arithmetic never leaves this file.
local zoom = 1.0
local ZOOM_MIN, ZOOM_MAX, ZOOM_STEP = 1.0, 3.0, 0.5

local function applyZoom(delta)
	zoom = math.max(ZOOM_MIN, math.min(ZOOM_MAX, zoom + delta))
	hl.dispatch(dsp.exec_cmd(string.format("hyprctl eval 'hl.config({cursor={zoom_factor=%.1f}})'", zoom)))
	hl.notification.create({
		text     = string.format("Zoom %.1fx", zoom),
		duration = 1200,
		color    = "rgba(" .. require("assets.mocha").blue .. "ee)",
		font_size = 13,
	})
end

bind(mainMod .. " + SHIFT + mouse_down", function() applyZoom(ZOOM_STEP) end)
bind(mainMod .. " + SHIFT + mouse_up", function() applyZoom(-ZOOM_STEP) end)
bind(mainMod .. " + SHIFT + Z", function()
	zoom = 1.0
	hl.dispatch(dsp.exec_cmd("hyprctl eval 'hl.config({cursor={zoom_factor=1.0}})'"))
end)

-- cursor:zoom_factor is a runtime keyword; reload resets it to the config value
hl.on("config.reloaded", function()
	hl.dispatch(dsp.exec_cmd(string.format("hyprctl eval 'hl.config({cursor={zoom_factor=%.1f}})'", zoom)))
end)

-- Launchers and scripts
bind(mainMod .. " + RETURN", dsp.exec_cmd(terminal))
bind(mainMod .. " + B", dsp.exec_cmd(browser))
bind(mainMod .. " + E", dsp.exec_cmd(fileManager))
bind("ALT + SPACE", dsp.exec_cmd("pkill rofi || rofi -show drun -modi drun,filebrowser,run,window"))
bind(mainMod .. " + W", dsp.exec_cmd(scripts .. "/wallpaperSelect.sh"))
bind(mainMod .. " + SHIFT + V", dsp.exec_cmd(scripts .. "/clipManager.sh"))

-- Screenshots
bind("ALT + SHIFT + 5", dsp.exec_cmd('grim -g "$(slurp)" - | wl-copy'))
bind("CTRL + ALT + SHIFT + 5", dsp.exec_cmd("grim"))
bind("Print", dsp.exec_cmd("grim"))

-- Brightness
bind("XF86MonBrightnessUp", dsp.exec_cmd('brightnessctl -q s +5% && notify-send -t 1000 -h string:x-canonical-private-synchronous:brightness "Brightness" "$(brightnessctl -m | awk -F, \'{print $4}\' )"'))
bind("XF86MonBrightnessDown", dsp.exec_cmd('brightnessctl -q s 5%- && notify-send -t 1000 -h string:x-canonical-private-synchronous:brightness "Brightness" "$(brightnessctl -m | awk -F, \'{print $4}\' )"'))

-- Volume
bind("XF86AudioRaiseVolume", dsp.exec_cmd('wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+ && notify-send -t 1000 -h string:x-canonical-private-synchronous:volume "Volume" "$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk \'{vol=int($2*100); muted=$3=="[MUTED]"?1:0; if(muted) print vol"% (MUTED)"; else print vol"%";}\' )"'))
bind("XF86AudioLowerVolume", dsp.exec_cmd('wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%- && notify-send -t 1000 -h string:x-canonical-private-synchronous:volume "Volume" "$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk \'{vol=int($2*100); muted=$3=="[MUTED]"?1:0; if(muted) print vol"% (MUTED)"; else print vol"%";}\' )"'))
bind("XF86AudioMute", dsp.exec_cmd('wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle && notify-send -t 1000 -h string:x-canonical-private-synchronous:volume "Volume" "$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk \'{vol=int($2*100); muted=$3=="[MUTED]"?1:0; if(muted) print "MUTED ("vol"%)"; else print vol"%";}\' )"'))
bind("XF86AudioMicMute", dsp.exec_cmd("pactl set-source-mute @DEFAULT_SOURCE@ toggle"))

-- Player
bind("XF86AudioPlay", dsp.exec_cmd("playerctl play-pause"))
bind("XF86AudioPause", dsp.exec_cmd("playerctl pause"))
bind("XF86AudioNext", dsp.exec_cmd("playerctl next"))
bind("XF86AudioPrev", dsp.exec_cmd("playerctl previous"))

-- Lock and session
bind(mainMod .. " + code:9", dsp.exec_cmd("wlogout"))
bind("XF86PowerOff", dsp.exec_cmd("hyprlock"))

-- Reload and bar
bind(mainMod .. " + CTRL + R", dsp.exec_cmd("hyprctl reload"))
bind(mainMod .. " + SHIFT + B", dsp.exec_cmd(waybar .. "/launch.sh"))
bind("CTRL + ALT + Delete", dsp.exit())
