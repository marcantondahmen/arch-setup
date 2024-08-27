#!/bin/bash

echo "--------------------------------------------------"
echo "Installing packages ..."

logDir="$HOME/.arch-setup-logs"
log="$logDir/$(date +%y%m%d-%H%M%S)-pacman-log.txt"
mkdir -p $logDir

sudo pacman -Syu --noconfirm --needed \
	autorandr \
	base-devel \
	bat \
	bluez \
	bluez-utils \
	brightnessctl \
	composer \
	cronie \
	curl \
	docker \
	docker-compose \
	dunst \
	fd \
	firefox \
	fuse3 \
	fzf \
	git \
	github-cli \
	gitui \
	gnome-keyring \
	hsetroot \
	keepassxc \
	libnotify \
	maim \
	man-db \
	neovim \
	networkmanager \
	network-manager-applet \
	nodejs \
	noto-fonts-emoji \
	npm \
	php \
	picom \
	playerctl \
	postgresql-libs \
	python \
	python-pip \
	python-pynvim \
	rclone \
	ripgrep \
	rofi \
	sad \
	starship \
	stow \
	tig \
	tlp \
	tmux \
	tree-sitter \
	ttf-jetbrains-mono-nerd \
	unzip \
	wezterm \
	xautolock \
	xclip \
	xorg-xinput \
	xss-lock \
	yazi \
	zsh 2>&1 | tee $log

yayDir="$HOME/.yay"
yayPkgs="autotiling google-chrome lazydocker polybar teams slack-desktop lssecret-git"
installedApps="$HOME/.cache/installed"

mkdir -p "$installedApps"

if [ ! -d "$yayDir" ]; then
	mkdir "$yayDir"
	cd "$yayDir"
	git clone https://aur.archlinux.org/yay.git
	cd yay
	makepkg -si
fi

for item in $yayPkgs; do
	echo "Installing $item ..."

	file="$installedApps/$item"

	if [ ! -f "$file" ]; then
		yay -S --answerdiff=None --noconfirm $item
		touch "$file"
	fi
done

# Clean caches
sudo pacman -Sc --noconfirm
sudo yay -Sc --noconfirm

# Replace i3lock with i3lock-color
i3lockInstalled="$installedApps/i3lock-color"

if [ ! -f "$i3lockInstalled" ]; then
	sudo pacman -R --noconfirm i3lock
	lockTemp="/tmp/i3lockColorBuild"
	mkdir -p $lockTemp

	(
		cd $lockTemp
		git clone https://github.com/Raymo111/i3lock-color.git
		cd i3lock-color
		bash install-i3lock-color.sh
		touch "$i3lockInstalled"
	)

	rm -rf $lockTemp
fi

xdg-settings set default-web-browser google-chrome.desktop

# Greeter config
greeterConf="/tmp/slick-greeter.conf"
echo "[Greeter]" >$greeterConf
echo "background=#1f2335" >>$greeterConf
mkdir -p /etc/lightdm
sudo mv $greeterConf /etc/lightdm/slick-greeter.conf

echo "--------------------------------------------------"
echo "Setting up NVM ..."

curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh | bash

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

nvm install --lts

echo "--------------------------------------------------"
echo "Setting up zsh ..."

chsh -s $(which zsh)

if [ ! -d "$HOME/.zsh/zsh-autosuggestions/" ]; then
	git clone https://github.com/zsh-users/zsh-autosuggestions ~/.zsh/zsh-autosuggestions
fi

echo "--------------------------------------------------"
echo "Setting up Docker ..."

sudo systemctl start docker.service
sudo systemctl enable docker.service
sudo usermod -aG docker $USER

if [ ! -f "$HOME/.gitconfig" ]; then
	echo "--------------------------------------------------"
	echo "Setting up Git and GitHub ..."

	read -p "Git username: " gitUser
	read -p "Git email: " gitEmail

	git config --global user.name "$gitUser"
	git config --global user.email "$gitEmail"

	gh auth setup-git
fi

echo "--------------------------------------------------"
echo "Cron service ..."

sudo systemctl enable cronie.service
sudo systemctl start cronie.service

echo "--------------------------------------------------"
echo "Power management service ..."

sudo systemctl enable tlp.service
sudo systemctl start tlp.service

echo "--------------------------------------------------"
echo "Bluetooth service ..."

sudo systemctl enable bluetooth.service
sudo systemctl start bluetooth.service

echo "--------------------------------------------------"
echo "Network services ..."

sudo mkdir -p "/etc/NetworkManager/conf.d"
iwdBackend="wifi_backend.conf"
echo "[device]" >$iwdBackend
echo "wifi.backend=iwd" >>$iwdBackend
sudo mv $iwdBackend /etc/NetworkManager/conf.d/

sudo systemctl enable systemd-networkd.service
sudo systemctl start systemd-networkd.service

sudo systemctl enable systemd-resolved.service
sudo systemctl start systemd-resolved.service

sudo systemctl enable NetworkManager.service
sudo systemctl start NetworkManager.service

timeSyncConf="timesyncd.conf"
echo "[Time]" >$timeSyncConf
echo "NTP=0.arch.pool.ntp.org 1.arch.pool.ntp.org 2.arch.pool.ntp.org 3.arch.pool.ntp.org" >>$timeSyncConf
echo "FallbackNTP=0.arch.pool.ntp.org 1.arch.pool.ntp.org 2.arch.pool.ntp.org 3.arch.pool.ntp.org" >>$timeSyncConf
sudo mv $timeSyncConf /etc/systemd/

sudo systemctl enable systemd-timesyncd.service
sudo systemctl start systemd-timesyncd.service

if [ ! -d "$HOME/dotfiles" ]; then
	echo "--------------------------------------------------"
	echo "Cloning dotfiles ..."

	(
		git clone https://github.com/marcantondahmen/dotfiles.git $HOME/dotfiles
		cd $HOME/dotfiles
		stow */
	)
fi

echo "--------------------------------------------------"
echo "Setting up Neovim ..."

if [ ! -d "$HOME/.config/nvim/" ]; then
	git clone https://github.com/marcantondahmen/nvim-config.git ~/.config/nvim
	npm install -g neovim
	npm install -g tree-sitter-cli
fi

echo
echo "Please open Neovim and run PackerSync command in order to install plugins."
echo
echo "Afterwards, reboot your machine!"
