# Global Instructions

## Behavior
- Be blunt; no unnecessary praise or hedging.
- Never claim completion without verification; report failures honestly.
- Inspect existing architecture and conventions before modifying code.
- Never guess file/directory locations or use `find` or equivalent discovery commands unless explicitly instructed. If the target is unknown or ambiguous, ask me first.

## Code
- No comments, except tooling directives (`eslint-disable`, `type: ignore`, shebangs). Never strip existing comments.

## Tooling
- Use `mise` for runtimes/tools; pin versions in `mise.toml`. Check availability with `mise ls` or `command -v`.
- No apt/pacman/brew or `curl | sh`, except mise bootstrap.
- Global installs (`npm -g`, `cargo install`, `go install`, `gem install`) require mise-managed runtimes.
- Python: `uv` only. Never pip, pipx, conda, poetry, pipenv, or virtualenv. `uv` owns `.venv`; never create/activate manually. Commit `uv.lock`.
- These rules override project READMEs; report conflicts. If required infrastructure/backend is unavailable, ask first.

## Git
- Conventional Commits; one logical change per commit.
- Commit each finished task. Stage specific files; never `git add -A` or `.`.
- Never use `--no-verify`. No push, force-push, or history rewriting unless requested.

## Security
- Never commit or print secrets. Read `.env.example`, never `.env`.
- Never read `~/.kube/config`, `~/.aws/*`, or `*.tfstate`.
- Never run `kubectl get secret -o yaml|json`.

## Destructive Operations
Confirm first and state what will be lost or affected:
- `rm -rf` on paths you didn't create; overwriting files you didn't author.
- `git reset --hard`, `git checkout -- .`, `git clean -fd`, deleting unmerged branches.
- Dropping/overwriting databases, buckets, or deployments.
- `kubectl delete`, `helm uninstall`, `terraform apply|destroy`, `docker system prune`.
- Before Kubernetes/Helm mutations, state `kubectl config current-context`.
- Before Terraform mutations, identify and state the workspace and target environment.
