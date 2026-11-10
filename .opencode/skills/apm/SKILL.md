---
name: apm
description: Use when adding, updating or removing APM packages and MCP servers for the global OpenCode config — apm.yml dependencies, apm.lock.yaml, lifecycle hooks, or deciding whether an MCP server belongs in apm.yml or opencode.json.
---

# APM (Agent Package Manager)

Global APM project lives in `config/apm/`, deployed to `~/.apm/`. APM reads `apm.yml` there and writes generated state (`.opencode/`, `.github/`, `.cursor/`, `AGENTS.md`, `apm.lock.yaml`, `apm_modules/`, `deployment-receipts/`, `logs/`) next to it. It also writes into the real `~/.config/opencode/`.

## What is linked, what is generated

Linked from this repo into `~/.apm/` (`FLAT_HOME_LIST` in `scripts/initialize.sh`): `apm.yml`, `config.json`, `marketplaces.json`, and the `.apm/` dir (so `~/.apm/.apm/instructions/global.instructions.md` resolves).

Generated, machine-local, **not committed**: everything else. `.gitignore` holds `config/apm/.agents/`, `.opencode/`, `.apm-local/`, `apm_modules/`, `opencode.json`, `.gitignore` itself.

`.apm/instructions/global.instructions.md` is the global instruction text APM compiles into every target's `AGENTS.md`. Edit it here, then re-run install.

## Add an APM package (skills, prompts, agents, hooks)

Run from `~/.apm` so the linked `apm.yml` is the one edited:

```bash
cd ~/.apm
apm install <owner>/<repo>            # append to dependencies.apm, write lockfile, deploy
apm install <owner>/<repo> --dry-run  # preview first when unsure
apm deps list                         # what is installed and what it deployed
apm update --yes                      # refresh refs, rewrite apm.lock.yaml, re-run hooks
```

Then commit `config/apm/apm.yml` only. The lockfile is machine-local by design and is regenerated from scratch by `apm install` on any machine.

`apm deps list` marks packages as `orphaned` when they exist in `apm_modules/` but not in the resolved graph. Those come from plugins installed outside apm (`opencode plugin add`). Do not run `apm prune` blind: it deletes them, and the matching lifecycle `pre-uninstall` hooks are the only thing that removes their OpenCode plugin entries.

## Add an MCP server

Two paths, pick per server:

- Managed by APM → goes into `apm.yml` under `dependencies.mcp`, with `registry: false` and an explicit `command`/`args`/`transport` for stdio servers, or `url` + `transport` for remote ones. Easiest via CLI from `~/.apm`:

  ```bash
  apm mcp install context7 --registry false -- mise exec -- npx -y @upstash/context7-mcp
  apm mcp install https-api --transport http --url https://example.com/mcp
  ```

- Hand-written in `~/.config/opencode/opencode.json` → AGENTS.md says the file is not in this repo, so a handwritten server is not reproducible. If a server must stay handwritten, say so and keep it out of `apm.yml`.

All current servers are stdio through `mise exec -- npx -y ...`, so the runtime comes from mise pinned versions and never from a global npm install.

## Lifecycle hooks

`apm.yml` runs command hooks on `post-install`, `post-update`, `pre-uninstall`. Today they install/refresh/remove the OpenCode plugins: caveman (via npx github), ponytail, `opencode-models-discovery`, superpowers, and rtk. Rule: any plugin added to `opencode.json` by hand must get a hook in all three lists, or a fresh machine ends up with a half-configured OpenCode.

## Verify

```bash
cd ~/.apm
apm install --frozen --dry-run    # manifest and lockfile agree; fetches the package over git
apm targets                       # which runtimes are active here (opencode should be active)
apm deps list                     # deployed files under .config/opencode/
git -C ~/Documents/Programming/Projects/dotfiles status --short config/apm
```

`git status` must show only `apm.yml` (and `.apm/instructions/`) when you changed config, never generated output.

## Gotchas

- `apm.yml` sets `targets: opencode`, but `apm targets` still reports copilot, cursor, windsurf active because APM auto-detects a target when its deploy dir exists. Generated `.github/`, `.cursor/`, `.windsurf/` live in `~/.apm/`, not in the repo.
- `apm.lock.yaml` pins commits. A `post-update` hook that aborts leaves the lockfile rewritten but plugins half-updated; re-run `apm install` before committing anything.
- Do not edit `~/.config/opencode/opencode.json` to change an APM-managed MCP server. Edit `apm.yml` and re-install, or the next `apm install` overwrites you.
- `config/apm/config.json` only sets `default_client`. `marketplaces.json` is intentionally empty.
