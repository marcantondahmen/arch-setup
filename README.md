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

## Post-Install

### Monitors

This setup includes [autorandr](https://github.com/phillipberndt/autorandr) that let's you easily save and change monitor configurations that have been created using `xrandr`.

In order to save the current setup, run:

```bash
autorandr --save somename
```

Run this to automatically load the current setup:

```bash
autorandr --change
```

#### Example

Setting up a dual-monitor configuration where a laptop has sometimes a secondary screen attached can be realized as follows:

1. First, only the laptop: Disconnect all other screens and run `xrandr` to configure the built-in screen. For example:

   ```bash
   xrandr --output eDP-1 --auto --scale 0.675
   ```

2. Save the _mobile_ config as follows:

   ```bash
   autorandr --save mobile
   ```

3. Reboot

4. Attach the secondary screen and also configure it using `xrandr`:

   ```bash
   xrandr --output eDP-1 --auto --scale 0.675
   xrandr --output DP-2 --auto --scale 1 --right-of eDP-1 --primary
   ```

5. Save the _home office_ configuration:

   ```bash
   autorandr --save home
   ```

Now changes of the connected monitors should be detected correctly.

### Cursor

Also it might be needed to set a correct size for the cursor. The cursor size can be defined by adding the following line to `~/.Xresources`:

```bash
Xcursor.size: 10
```

Then load the `.Xresources` in your `~/.xprofile`:

```bash
xrdb -merge ~/.Xresources
```

---

&copy; 2024 Marc Anton Dahmen, MIT license
