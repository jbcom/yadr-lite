#!/usr/bin/env zsh

# Common utilities for yadrlite setup scripts
# Dynamically resolve YADR_DIR based on the script's location
export YADR_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-${(%):-%x}}")/.." && pwd)"
export DOTFILES_OLD=backup

typeset -a YADR_FILES=('vim' 'vimrc' 'tmux.conf' 'bash_profile' 'bashrc' 'vimrc.after')
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
