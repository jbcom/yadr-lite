#!/usr/bin/env zsh
setopt nullglob

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "==> Installing default fonts (Linux)"
  mkdir -p ~/.local/share/fonts
  
  # Symlink local fonts on Linux since Homebrew casks aren't supported
  font_files=("$YADR_DIR"/workstation/fonts/*.ttf(N))
  if (( ${#font_files[@]} > 0 )); then
    for f in "${font_files[@]}"; do
      safe_symlink "$f" ~/.local/share/fonts/$(basename "$f")
    done
    if command -v fc-cache &>/dev/null; then
      fc-cache -fv ~/.local/share/fonts
    fi
  fi
fi
