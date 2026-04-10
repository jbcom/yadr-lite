#!/usr/bin/env zsh
setopt nullglob

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "==> Installing default fonts (Linux)"
  mkdir -p ~/.local/share/fonts
  
  # Fallback to copying local fonts on Linux since Homebrew casks aren't supported
  font_files=("$YADR_DIR"/workstation/fonts/*.ttf(N))
  if (( ${#font_files[@]} > 0 )); then
    cp "${font_files[@]}" ~/.local/share/fonts/
    if command -v fc-cache &>/dev/null; then
      fc-cache -fv ~/.local/share/fonts
    fi
  fi
fi
