#!/usr/bin/env zsh
setopt nullglob

# NOTE: this is a deliberate, documented exception to this project's
# Homebrew-only package policy (see AGENTS.md). i3/i3-gaps has no
# Homebrew/Linuxbrew formula — X11 window managers depend on system
# X11/Wayland libraries that Linuxbrew does not bottle — so there is
# no Brewfile-based path to install it on Linux. macOS still routes
# through `brew install --cask` as normal.
if [[ "$(uname -s)" == "Darwin" ]]; then
  echo "==> Installing AeroSpace (macOS)..."
  brew install --cask nikitabobko/tap/aerospace
elif [[ "$(uname -s)" == "Linux" ]]; then
  echo "==> Installing i3-gaps (Linux)..."
  if [ -f /etc/arch-release ]; then
    sudo pacman -S --needed --noconfirm i3-wm || sudo pacman -S --needed --noconfirm i3-gaps
  elif [ -f /etc/debian_version ]; then
    sudo add-apt-repository -y ppa:regolith-linux/release
    sudo apt update
    sudo apt install -y i3-gaps
  elif [ -f /etc/fedora-release ]; then
    sudo dnf install -y i3-gaps
  elif command -v xbps-install &>/dev/null; then
    sudo xbps-install -S i3-gaps
  elif command -v emerge &>/dev/null; then
    sudo emerge i3-gaps
  elif [ -f /etc/os-release ] && grep -q "opensuse" /etc/os-release; then
    sudo zypper install -y i3-gaps
  else
    echo "Warning: Unsupported Linux distribution for automatic i3-gaps installation."
  fi
elif [[ "$(uname -s)" == "FreeBSD" ]]; then
  sudo pkg install i3-gaps
fi
