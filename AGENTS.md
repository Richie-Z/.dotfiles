# AGENTS.md

Personal dotfiles for an Arch Linux (Hyprland/Wayland) + macOS setup. No build, tests, or lint. Files here are **live system config**: most are symlinked into `$HOME` / `~/.config`, so edits take effect immediately on the running shell/desktop. Verify before changing anything the user's session depends on.

## Layout

- `config/<name>/` → deployed as `~/.config/<name>` (kitty, waybar, rofi, yazi, tmux-ish tools, hypr, mise, KDE rc files at `config/` top level like `dolphinrc`).
- `config/zsh`, `config/bash`, `config/tmux`, `config/gtk` are special: their *contents* (dotfiles) link into `$HOME/` directly (e.g. `config/zsh/.zshrc` → `~/.zshrc`). This exception list is `IGNORED_LIST` in `scripts/initialize.sh` — update both places when adding a new `$HOME`-level dotfile dir.
- `config/.aliases` is NOT symlinked; `.zshrc` sources it in-place via `$DOTFILES_PATH`.
- `scripts/` — also sourced in-place at runtime (`env-detect.sh`, `clipboard.sh` via `.aliases`). `omz-init.sh` is a broken stub (bad shebang, empty body).
- `omz/themes/` — custom oh-my-zsh catppuccin theme (`ZSH_THEME="catppuccin"` in `.zshrc`). Not deployed by `initialize.sh`; must be installed into `$ZSH_CUSTOM/themes` manually.
- `packages/` — dated pacman dumps (`pacman -Qen` official / `-Qem` AUR). Regenerate with `scripts/dump-pkg.sh`, then commit the new dated files.
- `obsolete/` — dead configs and multi-MB tmux logs, still git-tracked. Ignore; don't resurrect or "clean up" without asking.

## Deploy

```bash
bash scripts/initialize.sh
```

Idempotent `ln -sf`. Never clobbers real files: an existing non-symlink target prints `Backup needed: <path>` and is skipped — if deployment "did nothing" for a path, that's why. `$DOTFILES_PATH` is hardcoded in `config/zsh/.zshenv` as `$HOME/Documents/Programming/Projects/dotfiles`; runtime-sourced scripts break if the repo moves.

## Hyprland: two parallel configs

- `config/hypr/` — **live** (`~/.config/hypr` symlink), classic `.conf` files sourced from `hyprland.conf`.
- `config/hypr-new/` — experimental `.lua` rewrite, **not deployed** (no `~/.config/hypr-new` exists). Editing it has zero effect on the running desktop. Keep the two in sync intentionally; don't delete either.

## Gotchas

- `~/.zshrc` ends with `unset HISTFILE` ("Private Shell") — intentional, not a bug to fix.
- `.zshenv` infers distro from display server: Wayland ⇒ Arch, Xorg ⇒ Debian. Weird but deliberate.
- `scripts/clipboard.sh` picks `wl-copy` / `xclip` / `pbcopy` via `env-detect.sh`; alias `ccc`. Requires `$DOTFILES_PATH` set. Over SSH (`detect_ssh` in `env-detect.sh` sees `$SSH_CONNECTION`/`$SSH_CLIENT`/`$SSH_TTY`) it ignores the remote display and emits an OSC 52 sequence so the copy lands on the *local* machine's clipboard (e.g. SSH into a headless Debian box from kitty).
- Toolchains (node, go, java, gcloud, helm, ...) are managed by mise; global config lives at `config/mise/config.toml` (symlinked to `~/.config/mise`).
- Shell completions in `.zshrc`: generated completions (podman, kubectl, gh, uv, bun, rustup, cargo, kubectl-neat, opencode) are **not** sourced with `source <(cmd completion zsh)`. Those generated files self-register via a `funcstack[1]`/`compdef` guard that misfires when sourced under oh-my-zsh + zsh-autocomplete, throwing `_arguments: can only be called from completion function` at startup. Instead `.zshrc` writes each into `$ZSH_COMPLETIONS_DIR` (`~/.cache/zsh/completions/`, machine-local, not committed), adds it to `$fpath`, and runs `compinit -C -d "$ZSH_COMPLETIONS_DIR/.zcompdump"` with a **dedicated dump file** (OMZ's own `$ZSH_COMPDUMP` is built before the dir is added and would keep them unresolved). Files regenerate only when older than the tool binary. Static completions in `/usr/share/zsh/site-functions` (pacman, yay, yazi, zoxide, eza, fd, rg, bat, mise, ...) autoload via `$fpath` and need no setup.
- No `.gitignore`; large logs in `obsolete/` are committed on purpose (or at least in fact) — don't add ignore rules retroactively without asking.
- Commit style seen in history: Conventional Commits, mostly `feat:` / `refactor:`, terse subjects.
