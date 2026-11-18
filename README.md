# dotfiles

My dotfiles

### setup

```bash
bash scripts/initialize.sh          # link configs into ~/.config and $HOME (--dry-run, --all, --no-prune)
bash scripts/omz-init.sh            # oh-my-zsh + external zsh plugins
bash scripts/tmux-init.sh           # tpm + tmux plugins from .tmux.conf
bash scripts/test-deploy.sh         # link/unlink smoke test in a temp HOME
```

`scripts/deploy-refind.sh` deploys the rEFInd rice to the ESP (Arch only, sudo). `scripts/dump-pkg.sh` refreshes `packages/`.

### todo

- Matugen
- Swaync

### opencode

Tracked config lives in `config/opencode/`, linked as a directory to `~/.config/opencode/`. OpenCode writes runtime state into it (`service.json`, `plugins/`, `skills/`), which `.gitignore` keeps out of git.

Plugins:

| Plugin | Source | Install | Uninstall |
| --- | --- | --- | --- |
| caveman | `github:JuliusBrussee/caveman` | `npx -y github:JuliusBrussee/caveman -- --only opencode --all --force` | `npx -y github:JuliusBrussee/caveman -- --uninstall --non-interactive` |
| ponytail | `@dietrichgebert/ponytail` | `opencode plugin add @dietrichgebert/ponytail` | `opencode plugin remove @dietrichgebert/ponytail` |
| models discovery | `opencode-models-discovery` | `opencode plugin add opencode-models-discovery` | `opencode plugin remove opencode-models-discovery` |
| superpowers | `superpowers@git+https://github.com/obra/superpowers.git` | `opencode plugin add superpowers@git+https://github.com/obra/superpowers.git` | `opencode plugin remove superpowers@git+https://github.com/obra/superpowers.git` |
| rtk | local `plugins/rtk.ts` | `rtk init --global --opencode` | `rtk init --uninstall --global --opencode` |

MCP servers:

| Server | Type | Command / URL |
| --- | --- | --- |
| playwright | local | `mise exec -- npx -y @playwright/mcp@latest --headless --browser=chromium` |
| context7 | local | `mise exec -- npx -y @upstash/context7-mcp` |
| penpot | remote | `https://penpot.dreadwrym.my.id/mcp/stream` |

Skills: caveman adds `caveman*`, `megacave`, `ultracave`, `cavecrew`; ponytail adds `ponytail*`; superpowers adds `brainstorming`, `test-driven-development`, `systematic-debugging` and 12 more. Project skills live in `.opencode/skills/`.

Secrets are files read by `.zshenv`: `~/.9router/api-key` becomes `NINEROUTER_API_KEY`, and `~/.penpot/{user-token,penpot-cf-access-client-id,penpot-cf-access-client-secret}` feed the penpot MCP server.
