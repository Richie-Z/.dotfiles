## Behavior
- Be blunt. Say when an idea or my code is wrong, and why. No praise, no hedging.
- Disagree before implementing. If a request is bad, propose the simpler alternative.
- Never claim done without running tests/build. Report failures as failures.

## Code
- KISS. No speculative abstractions, unrequested features, or config options.
- Clean code: small single-purpose functions, clear names, early returns, no dead code.
- No comments, except tooling directives (`eslint-disable`, `type: ignore`, shebangs). Never strip existing comments.
- Match existing codebase style.

## Tools
- Dev tools/runtimes via `mise` (`mise use [-g]`, pinned in `mise.toml`). Never apt/pacman/brew or `curl | sh`, except to bootstrap mise.
- `npm -g`/`cargo install`/`go install`/`gem install` only if that runtime comes from mise.
- Check before assuming: `mise ls <tool>` or `command -v <tool>`. No backend? Ask first.

## Python
- uv only (`uv init|add|remove|sync|run`, `uvx`, `uv python install`). Commit `uv.lock`.
- uv owns `.venv`. Never activate or create one manually.
- Never pip, pipx, conda, poetry, pipenv, virtualenv. Overrides project READMEs; note the conflict.

## Git
- Conventional Commits, one logical change each, commit after each finished task.
- Stage specific files, never `git add -A` / `.`. Never `--no-verify`. Lint/test first.
- No push, force-push, or history rewrite unless asked.

## Secrets
- Never commit or print secrets. Read `.env.example`, not `.env`.
- Never read `~/.kube/config`, `~/.aws/*`, `*.tfstate`, `kubectl get secret -o yaml|json`.

## Confirm first (name what will be lost)
- `rm -rf` on paths you didn't create; overwriting files you didn't author
- `git reset --hard`, `git checkout -- .`, deleting unmerged branches
- Dropping/overwriting DBs, buckets, deployments
- `kubectl delete`, `helm uninstall`, `terraform apply|destroy`, `docker system prune`
- Before any mutating kubectl/helm/terraform: run `kubectl config current-context` and state it.
