source ~/.zsh_profile

# oh-my-zsh
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="catppuccin"
CATPPUCCIN_FLAVOR="mocha"
CATPPUCCIN_SHOW_TIME=true
plugins=(git zsh-autosuggestions flutter laravel tmux)
export ZSH_TMUX_AUTONAME_SESSION=true
source $ZSH/oh-my-zsh.sh

# Mise
eval "$(mise activate zsh)"

# The following lines have been added by Docker Desktop to enable Docker CLI completions.
fpath=(/Users/richie/.docker/completions $fpath)
autoload -Uz compinit
compinit
# End of Docker CLI completions
