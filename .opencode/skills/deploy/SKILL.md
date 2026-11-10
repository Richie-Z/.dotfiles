---
name: deploy
description: Use when running or changing dotfiles deployment — initialize.sh, uninitialize.sh, link lists (REQUIREMENTS, IGNORED_LIST, FLAT_LIST, FLAT_HOME_LIST, SKIP_LIST), prune and backup behavior, rEFInd ESP deploy, or the deploy smoke test.
---

# Deploy

`scripts/initialize.sh` links `config/` into `$HOME` / `~/.config`. `scripts/uninitialize.sh` removes only links that point back into `config/`.

## Commands

```bash
bash scripts/initialize.sh              # link what this machine can use
bash scripts/initialize.sh --dry-run    # print planned ln/rm, touch nothing
bash scripts/initialize.sh --all        # ignore REQUIREMENTS, link every dir
bash scripts/initialize.sh --no-prune   # keep links of skipped configs
bash scripts/initialize.sh hypr waybar  # skip these config dirs (EXCLUDE_LIST)
bash scripts/uninitialize.sh            # remove our links
bash scripts/test-deploy.sh             # smoke test in a temp HOME
```

`initialize.sh` exits 1 if any link failed. Run `test-deploy.sh` after touching either script.

## How a dir is deployed

Decided by the lists at the top of `initialize.sh`:

| List | Members | Target |
| --- | --- | --- |
| `IGNORED_LIST` | `zsh` `tmux` `bash` `gtk` | contents → `$HOME/` |
| `FLAT_LIST` | `dolphin` | contents → `~/.config/` |
| `FLAT_HOME_LIST` | `apm` | contents → `~/.apm/` |
| `SKIP_LIST` | `refind` | never linked |
| none of them | everything else | dir → `~/.config/<name>` |

`REQUIREMENTS` is `<dir>:<command>:<os>`. Empty command or OS means "any". A command may list alternatives with `|` (binary name or absolute path, e.g. `moonlight|/Applications/Moonlight.app`). A dir with no entry is always linked. A skipped dir gets its old links pruned unless `--no-prune`.

## Gotchas

- `link()` runs `rm -f` before `ln -s`: `ln -sf src existing-dirlink` nests a link inside the dir, and `-n` / `-h` differ between GNU and BSD.
- A real file at the target is never clobbered. The script prints `Backup needed: <path>` and moves on, so a "missing" link usually means this.
- Prune only removes links whose `readlink` starts with `config/` (`unlink_if_ours` in `lib.sh`). Foreign symlinks and real files survive.
- `uninitialize.sh` duplicates the link lists but has no `REQUIREMENTS`: it unlinks regardless of installed apps. Adding a new dir that links into `$HOME`, flat, or `~/.<name>` means editing both scripts plus the Layout section of `AGENTS.md`.
- `--all` exists for machines missing the apps; the smoke test uses it too.

## rEFInd (ESP, Arch only)

```bash
bash scripts/deploy-refind.sh --dry-run
bash scripts/deploy-refind.sh            # sudo rsync into /boot/EFI/refind/
```

ESP is vfat: no symlinks, no ownership (`--no-owner --no-group`). No `--delete`, so stale files linger. `refind_x64.efi` and `BOOT.CSV` stay pacman-owned and are excluded. `refind_linux.conf` goes to `/boot/`, not the refind dir, because rEFInd reads it next to the kernel. Arch has no `os-release` on the ESP, so the script copies `os_arch.png` next to each `vmlinuz-*`.

## Other scripts

- `dump-pkg.sh` writes `packages/pacman-official-<date>.txt` (`-Qen`) and `pacman-aur-<date>.txt` (`-Qem`), temp file + `mv` so a failed pacman leaves no empty dump.
- `omz-init.sh` clones oh-my-zsh and the external plugins; `tmux-init.sh` clones tpm and installs plugins. Both are idempotent, and `tmux-init.sh` exits 0 when `tmux` or `git` is missing.
