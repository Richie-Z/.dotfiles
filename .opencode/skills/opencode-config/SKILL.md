---
name: opencode-config
description: Use when editing this repo's OpenCode setup — config/opencode/opencode.json or cli.json, adding providers or 9router models to the /models picker, MCP servers, agents, skills, permissions, secrets, reloading, or verifying the running service.
---

# OpenCode config

`config/opencode/` symlinks to `~/.config/opencode/`, so edits are live. V2 schema only; field meanings live in the global `opencode` skill and <https://opencode.ai/docs/>.

## Files

`opencode.json` holds providers, models, MCP, plugins, global agents, skills, permissions. `cli.json` holds TUI prefs only (theme, keybinds, tabs, diffs); never put those in `opencode.json`. Runtime state (`service.json`, `plugins/`, `skills/`, `commands/`, `agents/`, `.playwright-mcp/`, `*.bak`) is gitignored.

## Adding a 9router model

Gateway: `https://9router.dreadwrym.my.id/v1`, key in `~/.secret/9router-api-key`. OpenCode does not auto-import `/v1/models`; every model must be declared.

```bash
curl -sS -H "Authorization: Bearer $(cat ~/.secret/9router-api-key)" \
  https://9router.dreadwrym.my.id/v1/models \
| jq -e '.data[] | select(.id=="<id>")'
```

Add under `providers."9router".models`. Key and `modelID` must equal the gateway id; ids are case-sensitive. Map capabilities:

| Gateway | OpenCode |
| --- | --- |
| `vision: true` | `input: ["text","image"]`, else `["text"]` |
| `tools: true` | `tools: true` |
| `reasoning: true` | `reasoning.supported: true` |
| `thinkingCanDisable: true` | `toggle: true`; omit `effort` unless a real ladder exists |
| `thinkingCanDisable: false` | `toggle: false`; zai models also get `effort: ["thinking"]` |
| real ladder | `reasoning.effort: [low, medium, ...]` |
| `contextWindow` | `limit.context` |
| `maxOutput` / `max_completion_tokens` | `limit.output`, choose deliberately |

`thinkingFormat` and `thinkingCanDisable` are gateway-only; the schema rejects them. Combos are `owned_by: "combo"`. Keep one entry per model family; don't add provider routes that duplicate a combo.

## Reload and verify

```bash
opencode reload
opencode models | grep -Fx '9router/<id>'
opencode debug config \
| jq -r '.[] | select(.path|test("opencode.json$")) | .info.providers["9router"].models | keys[]'
opencode run --archived -m 9router/<id> 'Reply with exactly: ok'
```

`opencode models` and `debug config` reflect the running service, so they stay stale until `opencode reload`. The completion is the only proof the gateway accepts the id; the picker lists config entries regardless.

## JSONC

`opencode.json` allows trailing commas. `jq` and `python -m json.tool` reject it; that is not a bug. Validate the merged config via `opencode debug config` after reload, not the raw file. If it errors, the file failed to load.

## Gotchas

- Invalid JSON removes every 9router model at the next reload. Keep the edit to one block and reload before committing.
- Hot reload can fail with `inotify_add_watch ... .playwright-mcp`. `opencode reload` forces a rebuild; restart the service only if it is unhealthy.
- `thinking_levels` can be advertised but ignored: `nous/qwen/qwen4-max:free` used 33 reasoning tokens at `none`, `low`, `medium`, and `high`. Only `reasoning: {enabled: false}` actually disabled thinking there.
- `maxOutput` and `max_completion_tokens` often disagree (`FUCKING-FREE`: 128000 vs 32000).
- The provider `settings` block owns the key; no provider-level `apiKey` or per-model auth.
- Set `name` to the picker label, e.g. `<Model> (Combo)`.
- Never inline keys; use `{file:~/.secret/<name>}` (mode 700/600).
- The whole directory links into the repo. Check `git status`; stage only the edited file, never `git add config/opencode` or `-A`.
- Commit with a Conventional Commit, e.g. `feat(opencode): add <model> to 9router models`.
- A global `opencode` skill exists; project skill ids must differ.
