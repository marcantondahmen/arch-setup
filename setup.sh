#!/bin/bash

echo "--------------------------------------------------"
echo "Installing packages ..."

sudo pacman -Syu --noconfirm --needed \
	autorandr \
	base-devel \
	bat \
	brightnessctl \
	composer \
	curl \
	docker \
	docker-compose \
	dunst \
	fd \
	firefox \
	fzf \
	git \
	github-cli \
	gitui \
	gnome-keyring \
	hsetroot \
	libnotify \
	man-db \
	neovim \
	networkmanager \
	nodejs \
	npm \
	php \
	picom \
	python \
	python-pip \
	python-pynvim \
	ripgrep \
	rofi \
	sad \
	starship \
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
	yazi \
	zsh

sudo pacman -R --noconfirm i3lock

yayDir="$HOME/.yay"
yayPkgs="autotiling google-chrome lazydocker polybar i3lock-color"

if [ ! -d "$yayDir" ]; then
	mkdir "$yayDir"
	cd "$yayDir"
	git clone https://aur.archlinux.org/yay.git
	cd yay
	makepkg -si
fi

for item in $yayPkgs; do
	echo "Installing $item ..."

	file="$yayDir/.$item"

	if [ ! -f "$file" ]; then
		yay -S --norebuild --answerdiff=None --noconfirm $item
		touch "$file"
	fi
done

xdg-settings set default-web-browser google-chrome.desktop

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
echo "Power management service ..."

sudo systemctl enable tlp.service
sudo systemctl start tlp.service

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

if [ ! -d "$HOME/.dotfiles" ]; then
	echo "--------------------------------------------------"
	echo "Cloning dotfiles ..."

	git clone --bare https://github.com/marcantondahmen/arch-dotfiles.git $HOME/.dotfiles
	git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME config --local status.showUntrackedFiles no
	git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME checkout -f
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
