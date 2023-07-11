if [ -f ~/.bash_aliases ]; then
  . ~/.bash_aliases
fi

set -o vi

export PATH=$PATH:/home/richie/.spicetify:/sbin/

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

source ~/.local/share/blesh/ble.sh
 
eval "$(oh-my-posh init bash --config ~/oh-my-posh-themes/mt.omp.json)"
