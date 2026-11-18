# OpenCode

Tracked config lives in `config/opencode/`, linked as a directory to `~/.config/opencode/`. OpenCode writes runtime state into it (`service.json`, `plugins/`, `skills/`), which `.gitignore` keeps out of git.

Plugins:

| Plugin | Source | Install | Uninstall |
| --- | --- | --- | --- |
| superpowers | `superpowers@git+https://github.com/obra/superpowers.git` | `opencode plugin add superpowers@git+https://github.com/obra/superpowers.git` | `opencode plugin remove superpowers@git+https://github.com/obra/superpowers.git` |
| rtk | local `plugins/rtk.ts` | `rtk init --global --opencode` | `rtk init --uninstall --global --opencode` |

Skills (global, via the `skills` CLI into `~/.agents/skills/`, which OpenCode discovers; only `config/agents/.skill-lock.json` is tracked, and `~/.agents` is linked to `config/agents`):

| Skill | Source | Install |
| --- | --- | --- |
| caveman | `JuliusBrussee/caveman` | `npx -y skills add -g JuliusBrussee/caveman --skill caveman -y` |
| karpathy-guidelines | `multica-ai/andrej-karpathy-skills` | `npx -y skills add -g multica-ai/andrej-karpathy-skills --skill karpathy-guidelines -y` |
| ponytail | `DietrichGebert/ponytail` | `npx -y skills add -g DietrichGebert/ponytail --skill ponytail -y` |

Remove with `npx -y skills remove -g <skill>`.

Restore missing global skills on a fresh machine with `npx -y skills update -g -y`; it reads the tracked lock and refetches missing bodies.

Global skill installs and updates write the tracked lock at `config/agents/.skill-lock.json` and ignored bodies under `config/agents/skills/`; commit the lock change.

MCP servers (global):

| Server | Type | Command / URL |
| --- | --- | --- |
| context7 | local | `mise exec -- npx -y @upstash/context7-mcp` |

Playwright and Penpot are not global. Add them to the project that needs them.

Where the remaining skills come from: superpowers adds `brainstorming`, `test-driven-development`, `systematic-debugging` and 12 more.

Secrets live in `~/.secret/` (mode 700, files 600): `9router-api-key`. Config uses `{file:~/.secret/<name>}` so the OpenCode service reads them directly; it does not inherit shell exports.

## Scope: global vs project

Keep globally only what every project uses. A global skill costs one description line per prompt; a global MCP server costs tool schemas and a live connection in every session.

Global agent: add it under `agents` in `opencode.json` to keep it tracked. `agents/<name>.md` also loads globally, but that directory is gitignored here because plugins write into it.

Project skill: `.opencode/skills/<id>/SKILL.md` with `name` and `description` frontmatter. The directory name is the ID. No config entry needed.

Project MCP, run from the project root:

```sh
opencode mcp add <name> --url <url>                 # remote
opencode mcp add <name> -- npx -y <package>         # local
```

Omit `--global`; the command writes to the project config. `/mcps` connects or disconnects a server for the current session without editing files.

Turn off a global server in one project by redeclaring it in that project's config with `"disabled": true`. Repeat its `type` and `command` or `url`; the nearer config replaces the whole server object.

Do not toggle with `policies` `mcp.use` or `skill.use` denies. Policies evaluate broadest-last, so a global deny cannot be re-allowed by a project. Use a `permissions` deny for a skill instead:

```jsonc
{ "permissions": [{ "action": "skill", "resource": "<id>", "effect": "deny" }] }
```
