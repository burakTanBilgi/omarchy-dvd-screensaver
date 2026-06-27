#!/usr/bin/env bash
# Installer for omarchy-dvd-screensaver.
#
# Installs a mode-switchable DVD screensaver for Omarchy with two renderers:
#   browser : bouncing DVD-Video logo + corner-hit fireworks (Chromium kiosk)
#   ascii   : bouncing ASCII DVD logo in a terminal
# plus the stock Omarchy tte screensaver as "default", and "none" to disable.
#
# Conservative by design: every config edit is backed up first and skipped if
# already applied. Nothing in ~/.local/share/omarchy is touched.

set -euo pipefail
REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LBIN="$HOME/.local/bin"
OBIN="$HOME/.config/omarchy/bin"
SS="$HOME/.config/omarchy/screensaver"
BRAND="$HOME/.config/omarchy/branding"
ENVS="$HOME/.config/hypr/envs.conf"
HYPRIDLE="$HOME/.config/hypr/hypridle.conf"
MODEFILE="$HOME/.config/omarchy/screensaver-mode"
say(){ printf '==> %s\n' "$*"; }

# 1. scripts -> ~/.local/bin (these shadow the stock commands via PATH order)
say "Installing scripts to $LBIN"
for f in omarchy-screensaver-launch omarchy-screensaver omarchy-launch-screensaver \
         omarchy-cmd-screensaver omarchy-screensaver-menu; do
  install -Dm755 "$REPO/bin/$f" "$LBIN/$f"
done

# 2. browser renderer (launcher + self-contained page)
install -Dm755 "$REPO/config/omarchy/bin/omarchy-launch-dvd-screensaver" "$OBIN/omarchy-launch-dvd-screensaver"
install -Dm644 "$REPO/config/omarchy/screensaver/dvd.html"     "$SS/dvd.html"
install -Dm644 "$REPO/config/omarchy/screensaver/dvd-mask.png" "$SS/dvd-mask.png"

# 3. ASCII art
install -Dm644 "$REPO/branding/screensaver.txt" "$BRAND/screensaver.txt"

# 4. PATH: ensure ~/.local/bin shadows the stock omarchy bins for Hyprland children
if [[ -f "$ENVS" ]] && ! grep -q '\.local/bin' "$ENVS"; then
  say "Adding ~/.local/bin to Hyprland PATH ($ENVS)"
  cp "$ENVS" "$ENVS.bak.$(date +%s)"
  printf '\n# omarchy-dvd-screensaver: shadow stock screensaver commands\nenv = PATH,$HOME/.local/bin:$PATH\n' >> "$ENVS"
elif [[ ! -f "$ENVS" ]]; then
  say "NOTE: $ENVS not found — add: env = PATH,\$HOME/.local/bin:\$PATH"
fi

# 5. hypridle: point the screensaver timeout at our dispatcher (optional, safe)
if [[ -f "$HYPRIDLE" ]] && ! grep -q 'omarchy-screensaver-launch' "$HYPRIDLE"; then
  if grep -q 'omarchy-launch-screensaver' "$HYPRIDLE"; then
    say "Wiring hypridle on-timeout -> omarchy-screensaver-launch"
    cp "$HYPRIDLE" "$HYPRIDLE.bak.$(date +%s)"
    sed -i 's/omarchy-launch-screensaver/omarchy-screensaver-launch/g' "$HYPRIDLE"
  fi
fi

# 6. default mode: browser if chromium is available, else ascii
if [[ ! -f "$MODEFILE" ]]; then
  mkdir -p "$(dirname "$MODEFILE")"
  if command -v chromium >/dev/null; then echo browser > "$MODEFILE"; else echo ascii > "$MODEFILE"; fi
  say "Default screensaver mode: $(cat "$MODEFILE")"
fi

echo
say "Done. Apply with:  hyprctl reload && omarchy restart hypridle"
echo "    Preview now:   omarchy-launch-screensaver force"
echo "    Switch modes:  omarchy-screensaver-menu        (needs 'gum')"
