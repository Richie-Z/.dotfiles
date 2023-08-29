if [ -f ~/.bash_aliases ]; then
  . ~/.bash_aliases
fi

set -o vi

export PATH=$PATH:/home/richie/.spicetify:/sbin/:/home/richie/Development/flutter/bin:/opt/gradle/gradle-8.2.1/bin

export ANDROID_HOME=/home/richie/Android/Sdk
export PATH=$PATH:$ANDROID_HOME:$ANDROID_HOME/platform-tools:$ANDROID_HOME/build-tools/34.0.0:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/emulator

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

source ~/.local/share/blesh/ble.sh
 
eval "$(oh-my-posh init bash --config ~/oh-my-posh-themes/mt.omp.json)"
eval $(thefuck --alias)
