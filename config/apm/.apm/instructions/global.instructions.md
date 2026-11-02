# Global instructions

Applies to every session, in every project.

## Dev tools: mise (mandatory)

Use `mise` for every development tool and toolchain: compilers, language runtimes, CLIs, linters, formatters, and language servers.

- Install a tool with `mise use <tool>` (project) or `mise use -g <tool>` (global). Pin the version in `mise.toml`.
- Run tools through mise, so the pinned version applies.
- You MUST NOT install a dev tool with a system package manager (`apt`, `dnf`, `pacman`, `zypper`, `brew`, `snap`) or a `curl | sh` script.
- A language package manager may install a tool globally (`npm install -g`, `pnpm add -g`, `cargo install`, `go install`, `gem install`) only when that language's runtime comes from mise. Then the install lands inside the mise-managed runtime. A global install is lost when you change the runtime version; reinstalling it is fine, switching to a mise backend or a project-local dependency is better.
- You MUST NOT assume a tool exists. Check first with `mise ls <tool>` or `command -v <tool>`.
- If no mise backend exists for a tool, say so and ask before installing it another way.

## Python: uv (mandatory)

Use `uv` for all Python work. This rule overrides project READMEs and setup instructions that say otherwise; note the conflict when you override one.

- Create projects with `uv init`; run code with `uv run`; add and remove dependencies with `uv add` and `uv remove`; sync with `uv sync`; run one-off tools with `uvx`.
- Pin the interpreter in `.python-version` or `requires-python`, and fetch it with `uv python install`. Never rely on the system Python.
- Let `uv` manage the virtual environment. You MUST NOT create one with `python -m venv` or `virtualenv` by hand.
- Commit `uv.lock`. Keep configuration in `pyproject.toml` or `uv.toml`.
- You MUST NEVER use `pip`, `pip3`, `pipx`, `python -m pip`, `conda`, `poetry`, `pipenv`, or `virtualenv`.

A bare `python3` or `python` call is allowed only for a throwaway snippet outside any Python project, and only when `uv run` cannot serve the same purpose.

## Commits

Commit after finishing a task, using Conventional Commits (`type(scope): summary`).

- Keep one logical change per commit.
- Never commit secrets, credentials, or generated build output.
- You MUST NOT rewrite published history, force-push, or push unless asked.

## Secrets

- Never commit `.env`, credentials, keys, or tokens. Never print a secret value into the conversation, a file, or a log.
- Read `.env.example` for variable names, not `.env`.

## Destructive actions

Confirm first, and name what will be lost, before any of these:

- `rm -rf` on a path you did not create.
- `git reset --hard`, `git checkout -- .`, deleting a branch with unmerged work, or any history rewrite.
- A force-push, or any push to a shared branch.
- Dropping or overwriting a database, bucket, or deployment.
- Overwriting a file whose changes you did not author. Read it first.
