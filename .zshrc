source ~/.zsh_profile

# oh-my-zsh
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="zskai"
plugins=(git zsh-autosuggestions flutter laravel tmux)
export ZSH_TMUX_AUTONAME_SESSION=true
source $ZSH/oh-my-zsh.sh

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/Users/richie/miniforge3/bin/conda' 'shell.zsh' 'hook' 2>/dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/Users/richie/miniforge3/etc/profile.d/conda.sh" ]; then
        . "/Users/richie/miniforge3/etc/profile.d/conda.sh"
    else
        export PATH="/Users/richie/miniforge3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<
