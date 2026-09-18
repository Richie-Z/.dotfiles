local wallDIR = HOME .. "/Pictures/Wallpapers"

hl.on("hyprland.start", function()
	-- Startup
	hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
	hl.exec_cmd("systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
	-- Startup apps
	hl.exec_cmd("awww-daemon")
	hl.exec_cmd("waybar &")
	hl.exec_cmd("nm-applet --indicator &")
	hl.exec_cmd("hyprctl setcursor Bibata-Modern-Classic 20")
	hl.exec_cmd("hypridle &")
	--clipboard manager
	hl.exec_cmd("wl-paste --type text --watch cliphist store")
	hl.exec_cmd("wl-paste --type image --watch cliphist store")
end)
