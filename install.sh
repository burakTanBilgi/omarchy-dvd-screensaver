#!/usr/bin/env bash
# Installer for omarchy-dvd-screensaver.
# - Copies the screensaver script to ~/.local/bin
# - Copies the default ASCII art to ~/.config/omarchy/branding
# - Ensures ~/.local/bin is on Hyprland's PATH (so the shadow is picked up)

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_DST="$HOME/.local/bin/omarchy-cmd-screensaver"
ART_DST="$HOME/.config/omarchy/branding/screensaver.txt"
ENVS="$HOME/.config/hypr/envs.conf"

echo "==> Installing screensaver script to $BIN_DST"
install -Dm755 "$REPO_DIR/bin/omarchy-cmd-screensaver" "$BIN_DST"

echo "==> Installing default ASCII art to $ART_DST"
install -Dm644 "$REPO_DIR/branding/screensaver.txt" "$ART_DST"

# Make sure ~/.local/bin is on Hyprland's PATH so omarchy-launch-screensaver
# (which spawns alacritty via hyprctl exec) resolves our shadow.
if [[ -f "$ENVS" ]] && ! grep -q '\.local/bin' "$ENVS"; then
  echo "==> Adding ~/.local/bin to Hyprland PATH (in $ENVS)"
  printf '\n# Ensure ~/.local/bin shadows ship via PATH\nenv = PATH,$HOME/.local/bin:$PATH\n' >> "$ENVS"
  echo "    (run \`hyprctl reload\` to apply)"
elif [[ ! -f "$ENVS" ]]; then
  echo "==> $ENVS not found; skipping PATH tweak (you may need to add it manually)"
else
  echo "==> ~/.local/bin already present in $ENVS, no change needed"
fi

echo ""
echo "Done. Test with:"
echo "    omarchy-launch-screensaver force"
echo ""
echo "To uninstall:  rm $BIN_DST"
