# Marc's Arch Setup

This is a simple setup script that helps with installing applications, [dotfiles](https://github.com/marcantondahmen/arch-dotfiles) and a Neovim [configuration](https://github.com/marcantondahmen/nvim-config) to a fresh **Arch-Linux** machine in order to replicate a productive development environment based on **i3wm**, **tmux** and other minimalistic terminal apps.

> [!IMPORTANT]
> Please note that this is my personal setup script for my work machine. It helps to quickly replicate my development environment for my day job. Since your needs might differ, simply feel free to fork this repository and make it fully yours.

## Preperations

This setup assumes that Arch-Linux is installed using the `archinstall` command. During the installation process it is required that **i3** is selected as the window manager when selecting the environment. Also make sure to select `LightDM/slick-greeter` as your greeter.

When the installation has finished, simply boot into the fresh installation, open the default terminal with `Super+Return` and follow the steps below.

## Setup

1. Run the setup script as follows:
   ```bash
   curl -OL https://raw.githubusercontent.com/marcantondahmen/arch-setup/master/setup.sh
   bash setup.sh
   ```
2. Open Neovim and run `PackerSync`.
3. Reboot the machine.
4. Authenticate to GitHub using the `gh auth login`.

## Display and Cursor

The display resolution can be set with `xrandr`. For example scaling the resolution for a laptop screen can be done as follows:

```bash
xrandr --output eDP-1 --auto --scale 0.675
```

In order to persist display settigs, add the command above to `~/.xprofile`.

Also it might be needed to set a correct size for the cursor. The cursor size can be defined by adding the following line to `~/.Xresources`:

```bash
Xcursor.size: 10
```

Then load the `.Xresources` after the `xrandr` command in your `~/.xprofile`:

```bash
xrandr --output eDP-1 --auto --scale 0.675
xrdb -merge ~/.Xresources
```

---

&copy; 2024 Marc Anton Dahmen, MIT license
