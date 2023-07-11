# .dotfiles
my dotfiles (.)

## What's in it?
- [alacritty](https://github.com/alacritty/alacritty) (Terminal)
- [ble.sh](https://github.com/akinomyoga/ble.sh) (Bash completion +VIM mode)
- [oh-my-posh](https://github.com/JanDeDobbeleer/oh-my-posh) (Bash theme)
- [screenkey](https://gitlab.com/screenkey/screenkey) (For flex your keyboard-centricts environment 😎)
- [featherpad](https://github.com/tsujan/FeatherPad) (Lightweight text editor)
- [flameshot](https://github.com/flameshot-org/flameshot) (Screencapture)
- [xinit](https://gitlab.freedesktop.org/xorg/app/xinit) (Display server)
- [picom](https://github.com/yshui/picom/tree/stable/10) (Compositor for X display [used it for opacity and add shadow + rounded window])
- [i3](https://github.com/i3/i3.git) (For gigachad only)
	- [i3-scratchpad](https://gitlab.com/aquator/i3-scratchpad)
	- [diodon](https://github.com/diodon-dev/diodon) (clipboard manager)
- [polybar](https://github.com/polybar/polybar) (Panel)
	- [polybar-spotify](https://github.com/PrayagS/polybar-spotify)
- [rofi](https://github.com/davatorium/rofi) (Replacement for dmenu)
	- [rofi-power-menu](https://github.com/jluttine/rofi-power-menu/)
- [tmux](https://github.com/tmux/tmux) (For gigachad only)
	- [tpm](https://github.com/tmux-plugins/tpm)
- [vim](https://github.com/vim/vim.git) (THE BEST TEXT EDITOR IN UNIVERSE)
	- [vim-plug](https://github.com/junegunn/vim-plug.git) 
- [ranger](https://github.com/ranger/ranger) (Gigachad file explorer 😎)
	- [ranger_udisk_manager](https://github.com/SL-RU/ranger_udisk_menu)

## Installation steps for newbie
Prerequisite: `curl`
- [alacritty](https://github.com/alacritty/alacritty/blob/master/INSTALL.md)
- [ble.sh](https://github.com/akinomyoga/ble.sh/wiki/Manual-%C2%A71-Introduction#11-install--update)
- [xinit](https://www.thegeekdiary.com/startx-command-not-found/)
- [screenkey](https://gitlab.com/screenkey/screenkey#installation-and-basic-usage_)
- featherpad (you can install it via your current OS package manager)
- [flameshot](https://github.com/flameshot-org/flameshot#installation)
- [oh-my-posh](https://ohmyposh.dev/docs/installation/linux)
	-	Themes (the themes is stored at `~/oh-my-posh-themes`)
		1. create the folder
		```sh
		omp_dir=~/oh-my-posh-themes
		mkdir $omp_dir && cd $omp_dir 
		```
		2. download the file (my default theme  is [mt](https://github.com/JanDeDobbeleer/oh-my-posh/blob/main/themes/mt.omp.json))
		```sh
		curl -O https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/mt.omp.json
		```
	- [Fonts](#installing-fonts)
- [i3](https://i3wm.org/downloads/)
	- i3-scratchpad
	```sh
	cd ~/.config/i3/
	curl -O https://gitlab.com/aquator/i3-scratchpad/-/raw/master/i3-scratchpad
	chmod +x ./i3-scratchpad
	```
- [rofi]()
	- rofi-power-menu
	```sh
	cd ~/.config/rofi
	curl -O https://raw.githubusercontent.com/jluttine/rofi-power-menu/master/rofi-power-menu
	chmod +x ./rofi-power-menu
	```
- [tmux](https://github.com/tmux/tmux/wiki/Installing)
	- [tpm](https://github.com/tmux-plugins/tpm#installation)
- vim (you can install it via your current OS package manager)
	- [vim-plug](https://github.com/junegunn/vim-plug#vim)
	- colorsheme (molokai)
	```sh
	curl -o ~/.vim/colors https://raw.githubusercontent.com/tomasr/molokai/master/colors/molokai.vim
	```

### Installing Fonts
Currently all my dotfiles is using [Nerd Fonts](https://www.nerdfonts.com/):

1. FiraCode Nerd
```sh
curl -LO "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/FiraCode.zip" 
unzip -o FiraCode.zip -d ~/.fonts 
fc-cache -f -v
rm FiraCode.zip
```
2. JetBrainsMono Nerd
```sh
curl -LO "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/JetBrainsMono.zip" 
unzip -o JetBrainsMono.zip -d ~/.fonts 
fc-cache -f -v
rm JetBrainsMono.zip
```
3. MesloLG Nerd
```sh
curl -LO "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/Meslo.zip" 
unzip -o Meslo.zip -d ~/.fonts 
fc-cache -f -v
rm Meslo.zip
```
 
## My Other Configuration
- [Astrovim config](https://github.com/Richie-Z/astrovim-config) 
- [NvChad config](https://github.com/Richie-Z/nvchad-config)


### Todo
 - [ ] Better README
 - [ ] Add GTK installation guide
 - [ ] Add Ranger installation guide
 - [ ] Add Picom installation guide
 - [ ] Add Diodon installation guide
 - [ ] Add Polybar installation guide
