#!/usr/bin/env zsh
setopt nullglob

if [[ "$(uname -s)" == "Darwin" ]]; then
  for f in "${YADR_DYNAMIC_FONTS[@]}"; do
    echo "==> Dynamically installing font-${f}-nerd-font via Homebrew Cask..."
    brew install --cask "font-${f}-nerd-font" || echo "Warning: Could not install font-${f}-nerd-font. It may not exist in Homebrew Cask."
  done
else
  echo "==> Dynamic font installation via Homebrew Cask is only supported on macOS."
  echo "    Please install Fira Code Nerd Font manually via your package manager or copy it to ~/.local/share/fonts."
fi
