#!/bin/bash

echo "--------------------------------------------------"
echo "Installing packages ..."

sudo pacman -Syu --noconfirm --needed \
	base-devel \
	bat \
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
	man-db \
	neovim \
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
	tmux \
	tree-sitter \
	ttf-jetbrains-mono-nerd \
	unzip \
	wezterm \
	xautolock \
	xclip \
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
