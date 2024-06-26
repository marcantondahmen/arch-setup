# Marc's Arch Setup

This is a simple setup script that helps with installing all basic applications and cloning my personal dotfiles to a fresh **Arch-Linux** machine using the **i3** window manager.

> [!IMPORTANT]
> Please note that this script is my personal setup script and will clone my personal dotfiles as well. It helps to quickly replicate a productive development environment for my day job. Since your needs might differ, simply feel free to fork this repository and make it fully yours.

## Preperations

This setup assumes that Arch-Linux is installed using the `archinstall` command. During the installation process it is required that **i3** is selected as the window manager when selecting the environment. Also make sure to select `LightDM/slick-greeter` as your greeter.

When the installation has finished, simply boot into the fresh installation, open the default terminal with `Super+Return` and follow the steps below.

## Setup

1. Run the setup script as follows:
   ```bash
   wget -qO - https://raw.githubusercontent.com/marcantondahmen/arch-setup/master/setup.sh | bash
   ```
2. Open Neovim and run `PackerSync`.
3. Reboot the machine.
4. Authenticate to GitHub using the `gh auth login`.

---

&copy; 2024 Marc Anton Dahmen, MIT license
