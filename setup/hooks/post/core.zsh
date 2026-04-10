#!/usr/bin/env zsh
setopt nullglob

SHELL_RC=$(get_shell_rc)

if ! grep -q 'export PATH="$HOME/.local/bin' "$SHELL_RC" 2>/dev/null; then
  echo '' >>"$SHELL_RC"
  echo '# Local binaries' >>"$SHELL_RC"
  echo 'export PATH="$HOME/.local/bin:$PATH"' >>"$SHELL_RC"
fi

echo "# # Installing config files (kitty, nvim, ranger)"
mkdir -p ~/.config

for cfile in "${YADR_CONFIG[@]}"; do
  safe_symlink "$YADR_DIR/workstation/$cfile" ~/.config/$cfile
done
find ~/.config -type d -exec chmod 0755 {} \;
find ~/.config -type f -exec chmod 0644 {} \;
find ~/.config -name "*.sh" -execdir chmod u+x {} +

echo "==> Configuring Starship"
safe_symlink "$YADR_DIR/workstation/starship/starship.toml" ~/.config/starship.toml

if ! grep -q 'starship init zsh' "$SHELL_RC" 2>/dev/null; then
  echo '' >>"$SHELL_RC"
  echo '# Starship prompt' >>"$SHELL_RC"
  echo 'eval "$(starship init zsh)"' >>"$SHELL_RC"
fi


