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
