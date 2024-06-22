#! /bin/bash

tmpDir="/tmp/mad"

mkdir "$tmpDir"
cd "$tmpDir"

echo "Setting up Git and Yay ..."

sudo pacman -S --needed git base-devel

git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si

echo "--------------------------------------------------"
echo "Installing packages ..."

sudo pacman -Syu --noconfirm --needed \
	curl \
	wezterm \
	neovim \
	fzf \
	bat \
	tmux \
	gitui \
	github-cli \
	firefox \
	dunst \
	tig \
	starship \
	ripgrep \
	fd \
	sad \
	docker \
	docker-compose \
	zsh \
	python \
	python-pip \
	python-pynvim \
	nodejs \
	npm \
	ttf-jetbrains-mono-nerd

yay -S google-chrome
yay -S lazydocker

echo "--------------------------------------------------"
echo "Setting up NVM ..."

curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh | bash

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

nvm install --lts

echo "--------------------------------------------------"
echo "Setting up zsh ..."

chsh -s $(which zsh)
git clone https://github.com/zsh-users/zsh-autosuggestions ~/.zsh/zsh-autosuggestions

echo "--------------------------------------------------"
echo "Setting up Docker ..."

sudo systemctl start docker.service
sudo systemctl enable docker.service
sudo usermod -aG docker $USER

echo "--------------------------------------------------"
echo "Setting up Git and GitHub ..."

read -p "Git username: " gitUser
read -p "Git email: " gitEmail

git config --global user.name "$gitUser"
git config --global user.email "$gitEmail"

xdg-settings set default-web-browser firefox.desktop
gh auth login
gh auth status

echo "--------------------------------------------------"
echo "Cloning dotfiles ..."

git clone --bare https://github.com/marcantondahmen/arch-dotfiles.git $HOME/.dotfiles
git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME config --local status.showUntrackedFiles no
git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME checkout

echo "--------------------------------------------------"
echo "Setting up Neovim ..."

sudo npm install -g neovim

git clone https://github.com/marcantondahmen/nvim-config.git ~/.config/nvim

xdg-settings set default-web-browser google-chrome.desktop

rm -rf "$tmpDir"

echo "Open Neovim and run PackerSync command in order to install plugins."
