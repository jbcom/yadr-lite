#!/usr/bin/env zsh
setopt nullglob

SHELL_RC=$(get_shell_rc)

# Ensure ASDF is loaded in this sub-shell session if it exists so npm works
ASDF_DIR="$(brew --prefix asdf)/libexec"
if [ -f "$ASDF_DIR/asdf.sh" ]; then
  source "$ASDF_DIR/asdf.sh"
fi

echo "==> Configuring Global Packages & Tooling"

# Go lang installs (now managed by brew/asdf, but we still need paths)
export GOPATH="$HOME/go"
export PATH="$GOPATH/bin:$PATH"

if ! grep -q 'export GOPATH="$HOME/go"' "$SHELL_RC" 2>/dev/null; then
  echo '' >>"$SHELL_RC"
  echo '# Go paths' >>"$SHELL_RC"
  echo 'export GOPATH="$HOME/go"' >>"$SHELL_RC"
  echo 'export PATH="$GOPATH/bin:$PATH"' >>"$SHELL_RC"
fi
