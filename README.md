# omarchy-dvd-screensaver

The iconic bouncing **DVD-Video logo** as a screensaver for
[Omarchy](https://omarchy.org/) (Arch + Hyprland) — with the moment everyone
waits for: a **corner-hit fireworks finale**.

![DVD logo bouncing with a corner-hit fireworks show](docs/demo.gif)

Two renderers, switchable on the fly:

- **`browser`** — the real DVD-Video logo bouncing in a Chromium kiosk window.
  Cycles color + glow on every wall bounce, and when it nails a true corner it
  sets off a ~5-second randomized fireworks show.
- **`ascii`** — the logo as bouncing ASCII art in a fullscreen terminal. No
  Chromium, works anywhere.

Plus `default` (the stock Omarchy `tte` random-effects screensaver) and `none`
(disabled). It drops into Omarchy's existing screensaver pipeline — hypridle
timing, focus detection, and the screensaver-off toggle all keep working. **Any
key, mouse move, or focus loss exits instantly.**

## How it works

Omarchy idles into its screensaver like this:

```
hypridle (idle ~2.5 min)
   └─► omarchy-screensaver-launch        ← dispatcher (this project)
          reads ~/.config/omarchy/screensaver-mode and branches:
            browser → omarchy-launch-dvd-screensaver → chromium --kiosk dvd.html
            ascii   → (stock launcher) → terminal → omarchy-screensaver → omarchy-cmd-screensaver
            default → stock Omarchy tte screensaver
            none    → exit
```

The scripts install to `~/.local/bin`, which is placed **earlier on Hyprland's
PATH** than `~/.local/share/omarchy/bin`. That lets them *shadow* the stock
`omarchy-launch-screensaver` / `omarchy-screensaver` commands, so every entry
point (hypridle, the Omarchy menu, branding previews) honors the selected mode.
The real stock scripts are still invoked by full path when you pick `ascii` or
`default` — nothing in `~/.local/share/omarchy` is modified.

## Install

```bash
git clone https://github.com/burakTanBilgi/omarchy-dvd-screensaver.git
cd omarchy-dvd-screensaver
./install.sh
hyprctl reload && omarchy restart hypridle
```

`install.sh` copies the scripts and the DVD page, ensures `~/.local/bin` is on
Hyprland's PATH, points hypridle's timeout at the dispatcher, and sets a default
mode (`browser` if Chromium is installed, else `ascii`). **Every config edit is
backed up first and skipped if already present.**

### Requirements

- **browser mode:** `chromium`
- **ascii mode:** `python3` (ships with Omarchy)
- **mode menu:** `gum` (ships with Omarchy)

## Use

```bash
omarchy-launch-screensaver force     # preview the current mode now (move mouse to exit)
omarchy-screensaver-menu             # pick a mode (DVD ASCII / DVD browser / default / none)
```

Or set the mode directly:

```bash
echo browser > ~/.config/omarchy/screensaver-mode
```

## Customize

### The fireworks (browser mode)

All knobs live near the top of the relevant functions in
`~/.config/omarchy/screensaver/dvd.html`:

| What | Where | Default |
| --- | --- | --- |
| How close to a corner counts as a hit | `CORNER_TOL` | `8` px — raise it (e.g. `24`) to trigger fireworks more often |
| Show length / rhythm | the `times` array in `fireShow` | launches over ~4 s |
| Burst height band | `ty = rand(H()*0.12, H()*0.60)` in `launchVolley` | upper-middle |
| Bounce color palette | the `colors` array | neon set |

The logo is the real DVD-Video mark, embedded as a recolorable CSS mask
(`dvd-mask.png`, inlined as a `data:` URI so it works under `file://`).

### The ASCII art

Edit `~/.config/omarchy/branding/screensaver.txt`. The largest line sets the
bounding box. Speed lives at the top of `omarchy-cmd-screensaver`
(`MOVE_EVERY` — lower is faster).

## Uninstall

```bash
rm ~/.local/bin/{omarchy-screensaver-launch,omarchy-screensaver,omarchy-launch-screensaver,omarchy-cmd-screensaver,omarchy-screensaver-menu}
rm ~/.config/omarchy/bin/omarchy-launch-dvd-screensaver
echo default > ~/.config/omarchy/screensaver-mode
```

Removing the shadows restores the stock Omarchy screensaver via PATH
fallthrough. The PATH line in `envs.conf` is harmless to leave.

## See also

- [`omarchy-desktop-groups`](https://github.com/burakTanBilgi/omarchy-desktop-groups) — isolated desktop groups (bands of 10) on the number row
- [`omarchy-bg-random`](https://github.com/burakTanBilgi/omarchy-bg-random) — random / cyclable wallpapers for the active theme
- [`omarchy-waybar-tweaks`](https://github.com/burakTanBilgi/omarchy-waybar-tweaks) — clock seconds, workspace app icons, braille volume bar

## License

MIT — see [LICENSE](LICENSE).
