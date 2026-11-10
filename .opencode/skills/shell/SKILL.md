---
name: shell
description: Use when editing zsh startup files or shell tooling — .zshenv, .zshrc, completions.zsh, .aliases, env-detect.sh, clipboard.sh, lazy-loading wrappers, or completion cache/dump problems.
---

# Shell

Files: `config/zsh/.zshenv`, `config/zsh/.zshrc`, `config/zsh/completions.zsh`, `config/.aliases`, `config/zsh/.zprofile`, `scripts/env-detect.sh`, `scripts/clipboard.sh`. All deployed as live symlinks, so a syntax error breaks the next shell.

## Load order

1. `.zshenv` — every shell. Sets `PROGRAMMING_PATH`, `DOTFILES_PATH`, PATH, sources `env-detect.sh`, defines lazy loaders for `cargo`/`rustc`, `java`, `gcloud`.
2. `.zprofile` — login shells only. `brew shellenv zsh` on macOS.
3. `.zshrc` — interactive. Options, then `completions.zsh`, then `.aliases`, then the `y` yazi wrapper.
4. oh-my-zsh is **lazy**: `_zsh_lazy_load_omz` runs on the first `precmd`, not at startup. It sets `plugins=()`, sources `oh-my-zsh.sh`, sources the theme from `omz/themes/catppuccin.zsh-theme`, then zsh-autocomplete last.

`.aliases` is sourced in place from `$DOTFILES_PATH/config/.aliases`, not symlinked.

## Completions (`config/zsh/completions.zsh`)

Generated completions must not be sourced with `source <(cmd completion zsh)`. Those files self-register through a `funcstack[1]`/`compdef` guard that misfires under oh-my-zsh + zsh-autocomplete and throws `_arguments: can only be called from completion function` at every startup. Instead:

- Each tool writes to `$ZSH_COMPLETIONS_DIR` (`~/.cache/zsh/completions`, machine-local, not committed), which is added to `$fpath`.
- A file regenerates only when missing, older than the tool binary, or the cache stamp is over 24h old. A tool that is not on PATH is skipped, so its old file stays on disk and keeps loading until `completion-regen`.
- `compinit -C -d "$ZSH_COMPLETIONS_DIR/.zcompdump"` uses a **dedicated dump**. OMZ's own `$ZSH_COMPDUMP` is built before this dir joins `$fpath`, so it would never resolve these files.
- `completion-regen` (aliased `completion` through the `.zshrc-completion` wrapper) wipes the generated files, the stamp, and the dump, then `exec zsh`.
- To add a tool: append `"<fname> <command>"` to `_zsh_completion_specs`. The command must print a `#compdef`-headed script.
- Static completions in `/usr/share/zsh/site-functions` (pacman, yay, yazi, zoxide, eza, fd, rg, bat, mise) autoload via `$fpath`; no setup needed.
- `docker` reuses podman's completion via `compdef _podman docker`, because `docker` is a podman shim.

Lazy loaders keep startup fast: `mise`, `zoxide` (`z`, `zi`), `fzf`, `crossplane`, `helm`, `herdr`, `k3s`, `terraform` in `completions.zsh`; `cargo`, `rustc`, `java`, `gcloud` in `.zshenv`. Each wrapper `unfunction`s itself, activates the tool once, then runs it. A missing tool must stay harmless at startup.

## Clipboard (`scripts/clipboard.sh`, alias `ccc`)

`clipboard_copy` picks `pbcopy` on macOS, `wl-copy` on Wayland, `xclip -selection clipboard` on Xorg. Over SSH (`$SSH_CONNECTION`, `$SSH_CLIENT`, `$SSH_TTY`) it ignores the remote display and emits an OSC 52 sequence to the local terminal, so a copy on a headless remote box lands on the machine you are sitting at.

## Gotchas

- `.zshenv` derives `LINUX_DISTRO` from the display server (Wayland ⇒ arch, Xorg ⇒ debian). A headless Debian box yields `unknown`, so never gate portable logic on it. Check the binary instead: `cat` picks `batcat` or `bat` that way.
- The "Private Shell" block at the end of `.zshrc` is commented out; `unset HISTFILE` is not active. Re-enable it deliberately, it is not a bug.
- `$DOTFILES_PATH` is hardcoded in `.zshenv` as `$PROGRAMMING_PATH/Projects/dotfiles`. Runtime-sourced scripts break silently if the repo moves.
- A new external OMZ plugin goes in `scripts/omz-init.sh` (`EXTERNAL_PLUGINS`, optional third field pins a commit) and in `plugins=()` inside `_zsh_lazy_load_omz`. `zsh-completions` is deliberately absent from `plugins=()`, since OMZ would rebuild the dump a second time.
