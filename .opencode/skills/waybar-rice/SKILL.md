---
name: waybar-rice
description: Use when editing the waybar rice — module layout, format strings, icons or colors, style.css/mocha.css, reloading waybar, or verifying the result on screen with grim. Covers the dynamic island config and the pixel/glyph checks.
---

# Waybar rice

`config/waybar/` deploys to `~/.config/waybar`.

| File | Holds |
| --- | --- |
| `config.jsonc` | bar settings, `modules-center` order, `include` of `modules.jsonc` |
| `modules.jsonc` | module definitions, format strings, click handlers |
| `style.css` | layout, padding, module CSS classes |
| `mocha.css` | catppuccin mocha `@define-color` variables |
| `launch.sh` | toggle script: kills a running waybar, else starts it |

## Layout

Single centered "dynamic island": every module lives in `modules-center`, so left and right groups stay empty. Current order: `custom/arch`, `hyprland/workspaces`, `custom/media`, `idle_inhibitor`, `pulseaudio`, `network`, `battery`, `clock`, `custom/power`. Width comes from padding in `style.css`; `#custom-media label` carries `min-width: 180px` so the island does not jump when the player goes silent.

## Reload

```bash
pkill -SIGUSR2 waybar   # in-place config reload, PID unchanged means it worked
```

Super+Shift+B runs `launch.sh` (`config/hypr/keybindings.lua`), which is a **toggle**: first press `pkill -9 waybar`, second press starts it. Use the signal for reloads; use the keybind only when the bar is wedged.

## Colors and icons

- Per-icon accent color goes in the format string as pango: `"<span foreground='#f5c2e7'>󰎌</span> {}"`. CSS `@define-color` variables do not resolve inside spans, so hex is literal there.
- State colors are CSS classes on the module (`.warning`, `.critical` for battery and pulseaudio, `#idle_inhibitor.activated`), driven by the module's `states` thresholds.
- Icons are Nerd Font MDI literal characters, resolved through the `"Symbols Nerd Font"` fallback in the font stack. Do not add an explicit font per module.

## custom/media

`playerctl` reading spotify: `artist - title`, truncated to 44 chars, `—` when nothing plays. It is the island's middle spacer, so an empty player keeps the bar width stable. Click = play-pause, scroll up = next, scroll down = previous.

## Verify on screen

Never ship a rice change unverified.

1. `grim ~/shot.png` — full screen. `grim -g <geom>` is broken against the 3-monitor bounding box, so always capture full and crop.
2. Crop and zoom with `uv run --no-project --with pillow python` (PIL `Image.crop` + `resize`).
3. Read the PNG and measure: scan pixel runs for bar height, module width, and gaps. Do not eyeball.

## Glyph check

MDI codepoint names lie: U+F0954 renders as a filled clock blob, U+F034B is a magnifier, not music.

```bash
fc-list ':charset=0xf0954'   # is the glyph in some installed font
```

Render candidates at ~96px with PIL, Read the PNG, then commit to one.
