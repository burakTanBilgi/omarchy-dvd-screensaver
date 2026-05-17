# omarchy-dvd-screensaver

A bouncing DVD-logo screensaver for [Omarchy](https://omarchy.org/) — the iconic
early-2000s wallpaper, rendered as bouncing ASCII art in a fullscreen
terminal.

Replaces Omarchy's stock `tte` random-effects screensaver while keeping
every other piece of the existing screensaver pipeline (hypridle timing,
terminal class, focus detection, screensaver-off toggle) untouched.

## Demo

```
                                                                       ┌────────────────────────────┐
                                                                       │██████╗ ██╗   ██╗██████╗   │
                                                                       │██╔══██╗██║   ██║██╔══██╗  │
                                                                       │██║  ██║██║   ██║██║  ██║  │
                                                                       │██║  ██║╚██╗ ██╔╝██║  ██║  │
                                                                       │██████╔╝ ╚████╔╝ ██████╔╝  │
                                                                       │╚═════╝   ╚═══╝  ╚═════╝   │
                                                                       │       V I D E O           │
                                                                       └────────────────────────────┘
```

The logo drifts diagonally and bounces off all four edges of the
terminal. Any keypress, mouse-move, or focus loss exits.

## How it works

Omarchy's screensaver pipeline is:

```
hypridle (idle 2.5 min)
    └─► omarchy-launch-screensaver
            └─► opens alacritty/ghostty/kitty (class=org.omarchy.screensaver)
                    └─► runs `omarchy-cmd-screensaver`
                            └─► (stock) loops tte effects forever
```

This project ships a single Python file, `omarchy-cmd-screensaver`,
that's installed to `~/.local/bin/` so it shadows the stock command via
PATH precedence. Everything upstream of it stays as-is.

## Install

### Prerequisites

`~/.local/bin` must be earlier in your shell PATH than
`~/.local/share/omarchy/bin/`. On a default Omarchy install this is
true for interactive shells but **not** for processes spawned by
Hyprland — including the alacritty session the screensaver runs in.
Add this line to `~/.config/hypr/envs.conf` so Hyprland-spawned
children see `~/.local/bin` first:

```conf
env = PATH,$HOME/.local/bin:$PATH
```

Reload Hyprland: `hyprctl reload`.

### Install the screensaver itself

```bash
# Clone
git clone https://github.com/burakTanBilgi/omarchy-dvd-screensaver.git
cd omarchy-dvd-screensaver

# Run the installer
./install.sh
```

Or by hand:

```bash
install -Dm755 bin/omarchy-cmd-screensaver ~/.local/bin/omarchy-cmd-screensaver
install -Dm644 branding/screensaver.txt    ~/.config/omarchy/branding/screensaver.txt
```

### Try it

```bash
omarchy-launch-screensaver force
```

`force` skips the `screensaver-off` toggle check, useful for testing.

## Customize

### Change the ASCII art

Edit `~/.config/omarchy/branding/screensaver.txt`. The bouncer reads
this file at startup; the largest line determines the bounding box.
Try ASCII art generators or use figlet/toilet output.

### Speed / smoothness

Top of the Python file:

```python
FRAME_DELAY = 0.05   # 20fps loop — input/focus responsiveness
MOVE_EVERY  = 10     # ...but only step the logo every N frames (~2 cells/s)
```

Lower `MOVE_EVERY` for faster movement. Lower `FRAME_DELAY` for tighter
input response (the loop is the same for both).

### Color

The logo uses your terminal's foreground color (no explicit ANSI color
escape). To force a single color, replace the line that writes each
art row with:

```python
chunks.append(f"\033[{y + i + 1};{x + 1}H\033[38;5;201m{line}\033[0m")
```

(201 = hot pink in xterm-256.)

## Uninstall

```bash
rm ~/.local/bin/omarchy-cmd-screensaver
# (your stock omarchy-cmd-screensaver is restored automatically via PATH fallthrough)
```

The PATH line in `envs.conf` is harmless to leave in place but you can
remove it too if you have no other `~/.local/bin` overrides.

## How the bounce works

Position math uses reflection-past-edge so the logo only touches each
wall for one movement step. Hitting a corner just reflects on both
axes in the same step.

## See also

- [`omarchy-bg-random`](https://github.com/burakTanBilgi/omarchy-bg-random) — random / cyclable wallpapers for the active theme
- [`omarchy-waybar-tweaks`](https://github.com/burakTanBilgi/omarchy-waybar-tweaks) — clock seconds, workspace app icons, braille volume bar

## License

MIT
