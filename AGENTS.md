# AGENTS.md

Personal dotfiles for Arch Linux (Hyprland/Wayland) + macOS. No build, tests, or lint. Most files are **live system config**, symlinked into `$HOME` / `~/.config`, so edits hit the running shell and desktop immediately. This checkout is not always the machine that runs them: verify behavior against the files here, not against `$HOME`.

## Layout

- `config/<name>/` → `~/.config/<name>`. Run `ls config` for the current list; `REQUIREMENTS` in `scripts/initialize.sh` says which app each one needs.
- Link exceptions, duplicated in `scripts/initialize.sh` and `scripts/uninitialize.sh` — update both scripts when adding a dir:
  - `IGNORED_LIST` (`zsh`, `tmux`, `bash`, `gtk`): contents link into `$HOME/` (`config/zsh/.zshrc` → `~/.zshrc`).
  - `FLAT_LIST` (`dolphin`): contents link into `~/.config/` one file at a time, because KDE reads `dolphinrc` there.
  - `FLAT_HOME_LIST` (`apm`): contents link into `~/.apm/`.
  - `SKIP_LIST` (`refind`): ESP is vfat, cannot symlink. Deploy with `scripts/deploy-refind.sh`.
- `config/.aliases` is sourced in place by `.zshrc`, not linked.
- `scripts/` holds deploy tooling and runtime shell code (`env-detect.sh`, `clipboard.sh`, `lib.sh`).
- `omz/themes/` custom catppuccin theme; not deployed, install into `$ZSH_CUSTOM/themes` manually.
- `packages/` dated pacman dumps; refresh with `scripts/dump-pkg.sh` and commit the new files.
- `llm/` Ollama Modelfiles.
- `obsolete/` dead configs and multi-MB logs, git-tracked. Do not resurrect or clean up without asking.

## Deploy

```bash
bash scripts/initialize.sh
```

Idempotent `ln -sf`, skips a config whose app or OS is missing, prunes that config's old links, never overwrites a real file (`Backup needed: <path>`). `bash scripts/test-deploy.sh` proves link/unlink against a temp `$HOME`. Internals: `deploy` skill.

## Hyprland

One Lua config: `config/hypr/hyprland.lua` requires `monitors`, `workspaces`, `settings`, `environment`, `windows`, `animations`, `windowrules`, `startup`, `keybindings`. `hypridle.conf` and `hyprlock.conf` stay plain conf.

## Waybar

Centered "dynamic island": every module sits in `modules-center` (`config.jsonc`), definitions in `modules.jsonc`, styles in `style.css` + `mocha.css`. Rice changes: `waybar-rice` skill.

## Shell

Load order: `.zshenv` → `.zshrc` → `completions.zsh` → `.aliases`. Completion cache, lazy loaders, clipboard/OSC 52: `shell` skill.

## Gotchas

- `.zshenv` infers `LINUX_DISTRO` from the display server: Wayland ⇒ arch, Xorg ⇒ debian. Never gate portable logic on it, check the binary instead. `detect_os` returns only `mac` / `linux` / `unknown`.
- "Private Shell" block at the end of `.zshrc` is commented out, so `unset HISTFILE` is not active.
- `$DOTFILES_PATH` = `$PROGRAMMING_PATH/Projects/dotfiles`, set in `.zshenv`. Moving the repo breaks runtime-sourced scripts.
- `.gitignore` exists (btop log, stray apm output). Do not add rules retroactively without asking.
- Commit style: Conventional Commits, terse subjects.

## Skills

Project skills live in `.opencode/skills/`. Load one when the task matches:

- `deploy` — `initialize.sh` / `uninitialize.sh` internals, `REQUIREMENTS`, prune and backup behavior, rEFInd ESP deploy, deploy smoke test.
- `waybar-rice` — island layout, reload, pango colors, grim pixel verification, MDI glyphs.
- `shell` — completions cache and dump, lazy loaders, clipboard over SSH, distro inference quirk.
