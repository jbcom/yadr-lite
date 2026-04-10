#!/usr/bin/env zsh
setopt nullglob

SHELL_RC=$(get_shell_rc)

echo "==> Configuring Starship"
mkdir -p ~/.config
safe_symlink "$YADR_DIR/workstation/starship/starship.toml" ~/.config/starship.toml

if ! grep -q 'starship init zsh' "$SHELL_RC" 2>/dev/null; then
  echo '' >>"$SHELL_RC"
  echo '# Starship prompt' >>"$SHELL_RC"
  echo 'eval "$(starship init zsh)"' >>"$SHELL_RC"
fi
