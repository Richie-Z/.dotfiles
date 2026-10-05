# Hyprland Lua Rice — Design

**Date:** 2026-10-05
**Status:** Written, awaiting review
**Repo:** dotfiles (Arch Linux, Hyprland 0.56.2)

## Context

Hyprland 0.56.2 ships a first-class Lua config. This repo carries two parallel trees:

- `config/hypr/` — live, classic hyprlang `.conf` modules, symlinked to `~/.config/hypr`.
- `config/hypr-new/` — Lua rewrite, also symlinked to `~/.config/hypr-new`, but it has never loaded.

Two defects make `hypr-new` non-functional today:

1. `config/hypr-new/assets/mocha.lua` is 0 bytes.
2. `config/hypr-new/config/windows.lua` calls `require("~/.config/hypr/assets/mocha")`. Hyprland's Lua `require` never expands `~`; module names resolve relative to the directory containing the entry file, with dots becoming path separators. The module cannot be found.

`AGENTS.md` claims `hypr-new` is not deployed. That is stale: `scripts/initialize.sh` symlinks every top-level `config/` directory, so both trees are linked.

Hyprland prefers `hyprland.lua` over `hyprland.conf` when both exist. Confirmed by running `Hyprland --verify-config` against `~/.config/hypr`:

```
[cfg] Regular config at /home/u85/.config/hypr/hyprland.conf
[cfg] Lua config not found, using legacy config at /home/u85/.config/hypr/hyprland.conf
```

A Lua config that errors at load and registers no binds trips emergency mode, leaving a single working bind (`SUPER + Q`). Verification before deploy is therefore mandatory.

## Goals

- One Lua config tree, authoritative and live, that loads clean.
- Catppuccin mocha palette and minimal visual metrics preserved.
- Lua-only capabilities used where they replace shell hacks or remove duplication.
- A verifiable migration with a working rollback.

## Non-goals

- Waybar and rofi are untouched; they already match.
- Custom layout providers (`LuaLayoutProvider`) and layer-surface overlays are deferred.
- A palette generator between the `.lua` and `.conf` forms is not built.

## Decisions

| # | Decision | Rationale |
|---|---|---|
| 1 | Retire `.conf`; `config/hypr-new` content becomes `config/hypr` | Single source of truth, no sync burden |
| 2 | Scope is Hyprland core plus hyprlock/hypridle | Matches chosen ambition; waybar already good |
| 3 | Lua-native features and visual polish both | Explicit user choice: "everything" |
| 4 | Approach C: keep mechanical modules, rewrite expressive ones | Mechanical work is already correct; only what must change gets rewritten |

## Architecture

### File layout

```
config/hypr/
  hyprland.lua          entry; requires modules in fixed order
  monitors.lua          kept
  workspaces.lua        kept
  settings.lua          kept
  environment.lua       kept
  windowrules.lua       kept
  startup.lua           kept
  keybindings.lua       rewritten, data-driven
  windows.lua           rewritten, visual layer
  animations.lua        rewritten
  assets/mocha.lua      catppuccin mocha, returns a table
  assets/mocha.conf     same palette in hyprlang, for hyprlock only
  hyprlock.conf
  hypridle.conf
  scripts/clipManager.sh
  scripts/wallpaperSelect.sh
```

### Module resolution

Hyprland sets `package.path` relative to the entry file's directory. Confirmed from an actual error trace:

```
require("config.windows"): .../config/hypr-new/~//config/hypr/assets/mocha.lua
```

Rules:

- `require("settings")` resolves to `<entry dir>/settings.lua`.
- `require("assets.mocha")` resolves to `<entry dir>/assets/mocha.lua`.
- `~` is never expanded. Home-relative paths do not work.

### Flattening

Modules move from `config/hypr/config/*.lua` to `config/hypr/*.lua`. This removes the redundant `~/.config/hypr/config/` and shortens every require.

### Palette

`assets/mocha.lua` returns hex strings only:

```lua
return {
  rosewater = "f5e0dc",
  -- ...
  blue      = "89b4fa",
  -- ...
  crust     = "11111b",
}
```

Consumers compose Hyprland colors:

```lua
local c = require("assets.mocha")
local activeBorder = {
  colors = { "rgba(" .. c.mauve .. "ee)", "rgba(" .. c.blue .. "ee)" },
  angle  = 90,
}
```

`assets/mocha.conf` keeps the hyprlang form because hyprlock reads hyprlang, not Lua. The two files hold a frozen published palette (catppuccin mocha) and cannot drift, so no generator is warranted.

Note: `config/hypr-new/assets/` currently contains only the empty `mocha.lua`. The `mocha.conf` file exists solely in the old tree and must be copied into the new tree before the swap.

## Migration

Order matters. `~/.config/hypr` keeps serving the working `.conf` until step 5.

1. Copy `config/hypr/assets/mocha.conf` into `config/hypr-new/assets/` so the new tree is self-contained.
2. Repair requires and fill `assets/mocha.lua`. Gate: `Hyprland --verify-config -c config/hypr-new/hyprland.lua` prints `config ok`.
3. Run the event probe and runtime smoke tests (see Verification).
4. Rewrite `keybindings.lua`, verify. Rewrite `windows.lua`, verify. Rewrite `animations.lua`, verify. Fix the `hyprlock.conf` typo.
5. Green gate: `config ok`.
6. Move the old `.conf` tree to `obsolete/hypr-conf/`, including its `assets/mocha.conf`, for rollback. Move `config/hypr-new/*` into `config/hypr/`.
7. Remove the orphan `~/.config/hypr-new` symlink. `scripts/initialize.sh` never prunes stale links.
8. `hyprctl reload`, then `hyprctl configerrors`.

`hl.on("hyprland.start")` does not re-fire on reload, so startup effects apply at next login. This is correct: waybar, hypridle and cliphist are already running.

## Design detail

### windows.lua

| Change | Value |
|---|---|
| `gaps_in`, `gaps_out`, `border_size`, `rounding` | unchanged: 5, `8,8`, 1, 10 |
| `rounding_power` | **added**, `2` |
| smart gaps | **added**, `workspace_rule({ workspace = "w[tv1]", gaps_out = 0, gaps_in = 0 })` |
| `new_optimizations` | **removed**; absent from the 0.56 example, likely dropped |
| active border | unchanged: mauve to blue, 90 degrees |
| inactive border | unchanged: mantle at alpha `aa` |
| `dim_inactive`, opacities | unchanged: 0.2, and 1.0 / 0.9 / 1.0 |
| blur | unchanged: size 5, passes 1, xray, ignore_opacity |
| shadow | unchanged: range 32, render_power 2, surface1 at alpha `2e` |
| group bar | unchanged |

Rules: keep all four existing (`suppress-maximize-events`, `fix-xwayland-drags`, `move-hyprland-run`, pwvucontrol float). Add picture-in-picture:

```lua
hl.window_rule({
  name  = "picture-in-picture",
  match = { title = "Picture-in-Picture" },
  float = true,
  pin   = true,
  size  = { 480, 270 },
  center = true,
})
```

Covers Firefox and Chromium PiP. The 480x270 box is a starting value, tuned at the visual check.

### animations.lua

Keep the end-4 curve family and its attribution comment. Add the official spring:

```lua
hl.curve("easy", { type = "spring", mass = 1, stiffness = 238.1191, dampening = 24.21279333 })
```

Animation leaves:

| Leaf | Change |
|---|---|
| `windows`, `windowsIn`, `windowsOut` | keep (md3_decel/accel, popin 60%) |
| `border`, `fade`, `layersIn`, `layersOut`, `fadeLayersIn`, `fadeLayersOut`, `specialWorkspace` | keep |
| `workspaces` | keep |
| `workspacesIn`, `workspacesOut` | **added**, `slidefade 15%` |
| `zoomFactor` | **added**; zoom binds exist with no animation today |
| `global` | **added** |

### keybindings.lua

Data-driven rewrite:

- Workspaces 1 to 10 and their SHIFT and CTRL variants via `for i = 1, 10 do`. Removes roughly 40 copy-pasted lines.
- One direction table feeds arrow keys and HJKL, deleting the currently duplicated blocks.
- Both `-- TODO: manual review` markers resolved:
  - `workspaceopt allfloat` is dropped. It was never bound and no equivalent dispatcher is confirmed.
  - `changegroupactive` is dropped: `hl.dsp.changegroupactive` is `nil` in 0.56, so there is no shape to write against.
- Mouse binds gain `{ mouse = true }` per the official example; this is missing today.
- Volume, brightness, player and screenshot binds keep their existing shell commands. Their values are computed by shell tools and cannot be read back into Lua synchronously.

### Lua-native features

**Zoom controller.** A local Lua variable holds the zoom level (1.0 to 3.0, step 0.5). The bind updates it, runs `hyprctl keyword cursor:zoom_factor <value>`, and paints an OSD with `hl.notification.create`. This replaces the current `awk "BEGIN {print ...}"` expression embedded in the bind string.

**Notifications.**

```lua
hl.notification.create({
  text      = "...",
  duration  = 1500,
  icon      = "...",
  color     = "rgba(...)",
  font_size = 12,
})
```

Verified at load with a top-level smoke call before being wired into any handler.

**Event hooks.**

- `hyprland.start` — existing startup, unchanged behaviour.
- `hyprland.shutdown` — new, cleanup.
- `config.reloaded` — new, re-apply after reload.
- Window and workspace events are added only if the known-events probe confirms exact names.

`hl.on("unknown")` errors at load with `Known events:{...}`, so a wrong name is caught by the verify gate rather than failing silently.

**Timer.**

```lua
hl.timer({ timeout = 1800000, type = "repeat" }, function() ... end)
```

Used for opt-in wallpaper rotation through the existing `wallpaperSelect.sh`, behind one constant in `startup.lua` named `ROTATE_WALLPAPER`, defaulting to `false`.

**Shell-free kill.** SUPER+SHIFT+Q currently runs `hyprctl activewindow | grep pid | tr -d 'pid:' | xargs kill`. Target: `hl.get_windows()` plus a dispatcher. Whether a force-kill dispatcher exists is confirmed during step 3; the existing shell pipeline remains the fallback.

### Dispatchers

`hl.dsp.*` returns a dispatcher object. It must not be called directly:

```
dispatcher objects cannot be called directly; use hl.dispatch(d)
```

Pass the object straight to `hl.bind`, or wrap it in `hl.dispatch()` inside a Lua function handler.

### Deferred

| Feature | Why deferred |
|---|---|
| Custom layout providers | Layout math runs at runtime and `--verify-config` cannot reach it. A bad layout makes the desktop unusable, not merely ugly. |
| Layer-surface overlays | Same runtime-only exposure; geometry errors stay invisible until they fire. |

Both keep a clean slot: add `layout.lua` and `overlay.lua` and require them from `hyprland.lua`.

### hyprlock.conf

It sources `~/.config/hypr/assets/mocha.conf`, which survives the migration at the same path, so nothing breaks.

- Fix `dots_rouding = -1` to `dots_rounding = -1`. The typo is currently ignored silently.
- Layout, colors, fonts and `placeholder_text = Ask Richie` stay unchanged.

### hypridle.conf

No change proposed. It has no visual layer, and its timeouts (dim 150s, lock 300s, dpms 330s, suspend 1800s) are personal preference. Change only if requested.

## Verification

```bash
# Gate. Exit code is 0 even on failure, so assert on output.
Hyprland --verify-config -c <file> | grep -q "config ok"

# After swap
hyprctl reload
hyprctl configerrors
```

Sequence:

1. **Event probe.** A temporary file calling `hl.on("__probe__", function() end)`. The resulting error prints `Known events:{...}`. Capture the list, delete the probe.
2. **Runtime smoke.** Call `hl.notification.create` and `hl.timer` at top level so the gate exercises them.
3. **Per-module gates.** Verify after fixing requires, after the keybindings rewrite, after windows, after animations.
4. **Post-swap.** `hyprctl reload`, then `hyprctl configerrors` must be empty.
5. **Visual.** `grim` full-screen capture (geometry-scoped captures are broken against the 3-monitor bounding box), then crop and zoom with `uv run --no-project --with pillow python`, then Read the PNG. Measure gaps and corner rounding by scanning pixel runs, not by eye.

## Acceptance criteria

- `Hyprland --verify-config -c config/hypr/hyprland.lua` prints `config ok`.
- `hyprctl configerrors` is empty after reload.
- `~/.config/hypr-new` no longer exists; `obsolete/hypr-conf/` holds the old tree including its `assets/mocha.conf`.
- Every bind from the old config still exists, except `workspaceopt allfloat`, which is intentionally dropped.
- Smart gaps active: a single window on a workspace has zero gaps.
- `hyprlock` renders with the same palette as before.
- Screenshot evidence of gaps, rounding and border gradients accompanies the change.

## Rollback

1. A Lua load error with zero registered binds trips emergency mode, leaving `SUPER + Q` bound to a terminal.
2. Beyond that, switch to a TTY:

```bash
rm ~/.config/hypr
ln -s "$HOME/Documents/Programming/Projects/dotfiles/obsolete/hypr-conf" ~/.config/hypr
```

Do **not** re-run `scripts/initialize.sh` afterwards; it would relink `~/.config/hypr` back to the Lua tree.

## Risks and open items

| Item | Status |
|---|---|
| `new_optimizations` removed | Settled at first verify; restore if the gate rejects its absence |
| Force-kill dispatcher | Probed during implementation; shell fallback exists |
| Exact event names | Probed; only `hyprland.start`, `hyprland.shutdown`, `config.reloaded` are pre-confirmed |
| `dots_rounding` fix | Verified visually after the hyprlock change |
| `hl.timer` and `hl.notification.create` argument shapes | Taken from binary error strings; smoke-tested at top level before use |
| `assets/mocha.conf` availability in the new tree | Copied in migration step 1 |
