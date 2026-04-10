#!/usr/bin/env zsh
setopt nullglob

SHELL_RC=$(get_shell_rc)

if [[ "$USE_STARSHIP" == "1" ]]; then
  echo "==> Installing Starship via native sh installer"
  if ! command -v starship &>/dev/null; then
    curl -sS https://starship.rs/install.sh | sh -s -- -y -b ~/.local/bin >/dev/null
  fi

  mkdir -p ~/.config
  safe_symlink "$YADR_DIR/workstation/starship/starship.toml" ~/.config/starship.toml

  if ! grep -q 'starship init zsh' "$SHELL_RC" 2>/dev/null; then
    echo '' >>"$SHELL_RC"
    echo '# Starship prompt' >>"$SHELL_RC"
    echo 'eval "$(starship init zsh)"' >>"$SHELL_RC"
  fi
fi
