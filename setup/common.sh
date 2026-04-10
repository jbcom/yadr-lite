#!/usr/bin/env zsh

# Common utilities for yadrlite setup scripts
# Dynamically resolve YADR_DIR based on the script's location
export YADR_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-${(%):-%x}}")/.." && pwd)"
export DOTFILES_OLD=backup

typeset -a YADR_FILES=('vim' 'vimrc' 'tmux.conf' 'zshrc' 'vimrc.after')
typeset -a YADR_CONFIG=('kitty' 'nvim' 'ranger')
typeset -a YADR_TMUX_PLUGINS=('https://github.com/tmux-plugins/tmux-resurrect.git' 'https://github.com/tmux-plugins/tmux-sensible' 'https://github.com/wfxr/tmux-power.git')

sed_i() {
  if [[ "$(uname)" == "Darwin" ]]; then
    sed -i '' "$@"
  else
    sed -i "$@"
  fi
}

get_shell_rc() {
  echo "$HOME/.zshrc"
}

# Creates a symlink, backing up or failing safely if a non-symlink file already exists
safe_symlink() {
  local target="$1"
  local link_name="$2"

  if [[ -e "$link_name" || -L "$link_name" ]]; then
    if [[ "$FORCE" == "1" ]]; then
      echo "  -> Force replacing existing path: $link_name"
      rm -rf "$link_name"
    else
      # If it's already a symlink pointing to the right place, do nothing
      if [[ -L "$link_name" && "$(readlink "$link_name")" == "$target" ]]; then
        return 0
      fi
      echo "Warning: Path already exists and --force not specified. Skipping symlink: $link_name"
      return 1
    fi
  fi

  ln -s "$target" "$link_name"
}
