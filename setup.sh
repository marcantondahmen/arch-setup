#!/bin/bash

NVIM_VERSION="0.11.7"

echo "--------------------------------------------------"
echo "Configure ignored packages ..."

sudo sed -i 's/^#\?\s*IgnorePkg.*/IgnorePkg = linux-surface linux-surface-headers linux linux-headers linux-lts linux-lts-headers/' /etc/pacman.conf
cat /etc/pacman.conf | grep ^IgnorePkg

echo "--------------------------------------------------"
echo "Installing packages ..."

logDir="$HOME/.arch-setup-logs"
log="$logDir/$(date +%y%m%d-%H%M%S)-pacman-log.txt"
mkdir -p $logDir

sudo pacman \
	-Syu \
	--noconfirm \
	--needed \
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
	gcr-4 \
	gnome-keyring \
	hsetroot \
	keepassxc \
	inter-font \
	jq \
	libnotify \
	maim \
	man-db \
	networkmanager \
	network-manager-applet \
	nodejs \
	noto-fonts \
	noto-fonts-cjk \
	noto-fonts-emoji \
	npm \
	php \
	php-gd \
	picom \
	playerctl \
	postgresql-libs \
	python \
	python-pip \
	python-pynvim \
	p7zip \
	rclone \
	ripgrep \
	rofi \
	rsync \
	sad \
	starship \
	stow \
	terminus-font \
	tig \
	tlp \
	tmux \
	tree-sitter \
	ttf-jetbrains-mono-nerd \
	unzip \
	wezterm \
	xclip \
	xorg-xinput \
	xss-lock \
	yazi \
	zsh 2>&1 | tee $log

# Install pinned Neovim version.
sudo pacman -Rs neovim 2>/dev/null

nvimDir=/opt/nvim/${NVIM_VERSION}

if [ ! -d "$nvimDir" ]; then
	echo "Installing Neovim v${NVIM_VERSION} ..."

	(
		cd /tmp
		curl -LO https://github.com/neovim/neovim/releases/download/v${NVIM_VERSION}/nvim-linux-x86_64.tar.gz
		tar xzf nvim-linux-x86_64.tar.gz
		sudo mkdir -p $(dirname "$nvimDir")
		sudo mv nvim-linux-x86_64 $nvimDir
		rm nvim-linux-x86_64.tar.gz
		sudo ln -sf $nvimDir/bin/nvim /usr/local/bin/nvim
	)
fi

yayDir="$HOME/.yay"
yayPkgs="autotiling aws-cli-v2 google-chrome lazydocker polybar teams slack-desktop lssecret-git xautolock"
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

if [ ! -d "$HOME/.nvm" ]; then
	echo "--------------------------------------------------"
	echo "Setting up NVM ..."

	curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh | bash

	export NVM_DIR="$HOME/.nvm"
	[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

	nvm install --lts
else
	curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh | bash
fi

echo "--------------------------------------------------"
echo "Setting up zsh ..."

chsh -s $(which zsh)

if [ ! -d "$HOME/.zsh/zsh-autosuggestions/" ]; then
	git clone https://github.com/zsh-users/zsh-autosuggestions ~/.zsh/zsh-autosuggestions
fi

echo "--------------------------------------------------"
echo "Setting up ssh-agent ..."
export SSH_AUTH_SOCK=$XDG_RUNTIME_DIR/gcr/ssh
systemctl --user enable gcr-ssh-agent.socket
systemctl --user start gcr-ssh-agent.socket
echo 'export SSH_AUTH_SOCK=$XDG_RUNTIME_DIR/gcr/ssh' >ssh_auth_gcr.sh
sudo mv ssh_auth_gcr.sh /etc/profile.d/ssh_auth_gcr.sh

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
		git remote set-url origin git@github.com:marcantondahmen/dotfiles.git
		pwd
		git remote -v
	)
fi

if [ ! -d "$HOME/.config/nvim/" ]; then
	echo "--------------------------------------------------"
	echo "Setting up Neovim ..."

	git clone https://github.com/marcantondahmen/nvim-config.git ~/.config/nvim
	npm install -g neovim
	npm install -g tree-sitter-cli

	(
		cd "$HOME/.config/nvim/"
		git remote set-url origin git@github.com:marcantondahmen/nvim-config.git
		pwd
		git remote -v
	)

	echo
	echo "Please open Neovim and run PackerSync command in order to install plugins."
fi

echo
echo "Please reboot your machine!"
