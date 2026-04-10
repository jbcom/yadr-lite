#!/usr/bin/env zsh

# Workstation Management Orchestrator
source "$(dirname "$0")/setup/common.sh"

action="${1:-setup}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-${(%):-%x}}")" && pwd)"

# Legacy compat: run specific files if invoked directly
if [[ -x "$SCRIPT_DIR/setup/${action}.sh" && "$action" != "setup" ]]; then
  "$SCRIPT_DIR/setup/${action}.sh"
  exit $?
fi

# Argument parsing for scalable setup
OS_OVERRIDE=""
typeset -a FEATURES=()
typeset -a YADR_ASDF_LANGS=()
typeset -a YADR_DYNAMIC_FONTS=()
USE_ASDF=1
MIGRATE=0
UPGRADE=0
HAS_MACOS_FLAG=0
HAS_LINUX_FLAG=0

for arg in "$@"; do
  case $arg in
    --macos)
      OS_OVERRIDE="Darwin"
      HAS_MACOS_FLAG=1
      ;;
    --linux)
      OS_OVERRIDE="Linux"
      HAS_LINUX_FLAG=1
      ;;
    --without-asdf) USE_ASDF=0 ;;
    --migrate) MIGRATE=1 ;;
    --upgrade) UPGRADE=1 ;;
    --force) FORCE=1 ;;
    --with-langs)
      FEATURES+=("langs")
      YADR_ASDF_LANGS+=("all")
      ;;
    --with-lang-*)
      FEATURES+=("langs")
      YADR_ASDF_LANGS+=("${arg#--with-lang-}")
      ;;
    --with-font-*)
      FEATURES+=("dynamic-font")
      YADR_DYNAMIC_FONTS+=("${arg#--with-font-}")
      ;;
    --with-tiling-wm)
      FEATURES+=("tiling-wm")
      ;;
    --with-ai)
      FEATURES+=("ai")
      ;;
    --with-*) FEATURES+=("${arg#--with-}") ;;
    setup | help) ;;
    *)
      # Alias backward compatibility
      if [[ "$arg" != -* ]]; then
        if [[ "$arg" == "macos" ]]; then
          OS_OVERRIDE="Darwin"
          FEATURES+=("macos" "tiling-wm")
        fi
        if [[ "$arg" == "omarchy" || "$arg" == "linux" ]]; then
          OS_OVERRIDE="Linux"
          FEATURES+=("linux" "tiling-wm")
        fi
        if [[ "$arg" == "tools" ]]; then
          FEATURES+=("langs")
          YADR_ASDF_LANGS+=("golang" "python" "php")
        fi
        if [[ "$arg" == "ai" ]]; then FEATURES+=("ai"); fi
        if [[ "$arg" == "keyboard" ]]; then FEATURES+=("keyboard"); fi
        if [[ "$arg" == "gnu" || "$arg" == "linuxify" ]]; then FEATURES+=("gnu"); fi
        if [[ "$arg" == "update" || "$arg" == "upgrade" ]]; then UPGRADE=1; fi
      else
        echo "Unknown argument: $arg"
        exit 1
      fi
      ;;
  esac
done

if [[ "$action" == "remove" || "$action" == "uninstall" ]]; then
  shift # Remove 'remove' or 'uninstall' from args
  exec "$SCRIPT_DIR/uninstall.sh" "$@"
fi

if [[ "$HAS_MACOS_FLAG" -eq 1 && "$HAS_LINUX_FLAG" -eq 1 ]]; then
  echo "Error: --macos and --linux are mutually exclusive override flags. You can only specify one."
  exit 1
fi

if [[ "$action" == "help" ]]; then
  echo "YADRLite Setup Management"
  echo "Usage: ./setup.zsh [--macos | --linux] [--with-<feature>...] [--migrate] [--upgrade]"
  echo ""
  echo "OS Selection:"
  echo "  (Autodetects by default)"
  echo "  --macos   Force setup as macOS"
  echo "  --linux   Force setup as Linux"
  echo ""
  echo "Features dynamically load from 'brewfiles/<feature>.Brewfile' or 'setup/hooks/pre|post/<feature>.zsh'"
  echo "Example 1: ./setup.zsh --macos --with-gnu --with-keyboard"
  echo "Example 2: ./setup.zsh --with-langs                # Installs node, python, ruby, golang, php via asdf"
  echo "Example 3: ./setup.zsh --with-lang-ruby-3.2.0      # Installs a specific language and version via asdf"
  echo "Example 4: ./setup.zsh --with-tiling-wm            # Installs AeroSpace (macOS) or i3-gaps (Linux)"
  echo "Example 5: ./setup.zsh --with-ai                   # Installs gemini-cli, claude-code, codex"
  echo "Example 6: ./setup.zsh --with-langs --without-asdf # Installs node via nvm and go via g-install instead"
  echo ""
  echo "Maintenance:"
  echo "  --upgrade     Update repository and plugins"
  echo "  --migrate     Run sequential version migrations"
  exit 0
fi

if [[ "$UPGRADE" == "1" ]]; then
  echo "==> Updating YADRLite repository..."
  cd "$YADR_DIR"
  git pull --rebase

  echo "==> Updating tmux plugins..."
  mkdir -p "$YADR_DIR/tmux/plugin"
  for tplug in "${YADR_TMUX_PLUGINS[@]}"; do
    plugname=$(basename "$tplug" .git)
    if [ ! -d "$YADR_DIR/tmux/plugin/$plugname" ]; then
      echo "  -> Installing $plugname..."
      git clone "$tplug" "$YADR_DIR/tmux/plugin/$plugname"
    fi
  done
  for pdir in "$YADR_DIR"/tmux/plugin/*(/N); do
    if [ -d "$pdir/.git" ]; then
      echo "  -> Updating ${pdir:t}..."
      (cd "$pdir" && git pull --rebase)
    fi
  done
fi

# Version Management
CURRENT_VERSION="1.0.0"
if [[ -f "$SCRIPT_DIR/VERSION" ]]; then
  CURRENT_VERSION="$(cat "$SCRIPT_DIR/VERSION")"
fi

INSTALLED_VERSION="1.0.0"
if [[ -f "$YADR_DIR/.installed_version" ]]; then
  INSTALLED_VERSION="$(cat "$YADR_DIR/.installed_version")"
fi

version_gt() {
  test "$(printf '%s\n' "$@" | sort -V | head -n 1)" != "$1"
}

OS="${OS_OVERRIDE:-$(uname -s)}"
OS_LOWER="${(L)OS}"
if [[ "$OS_LOWER" == "darwin" ]]; then OS_LOWER="macos"; fi

# Core CLI Tools are always present

# Language fallback path for --without-asdf
if ((${FEATURES[(Ie)langs]})) && [[ "$USE_ASDF" == "0" ]]; then
  FEATURES+=("nvm" "golang-legacy" "python-legacy" "php-legacy")
fi

# Deduplicate features and reorder
FEATURES=("${(@u)FEATURES}")

reorder_feature_first() {
  local target_feat="$1"
  if ((${FEATURES[(Ie)$target_feat]})); then
    FEATURES=("$target_feat" "${FEATURES[@]:#$target_feat}")
  fi
}

reorder_feature_first "fonts"
reorder_feature_first "dynamic-font"
reorder_feature_first "nvm"
reorder_feature_first "golang-legacy"
reorder_feature_first "python-legacy"
reorder_feature_first "php-legacy"
reorder_feature_first "langs"

export USE_ASDF
export YADR_DYNAMIC_FONTS
export FORCE

# Generate .tool-versions file for ASDF
TOOL_VERSIONS="$YADR_DIR/.tool-versions"
touch "$TOOL_VERSIONS"

if [[ "$USE_ASDF" == "1" ]]; then
  for req in "${YADR_ASDF_LANGS[@]}"; do
    if [[ "$req" == "all" ]]; then
      echo "python latest\nruby latest\ngolang latest\nphp latest" >> "$TOOL_VERSIONS"
    elif [[ "$req" =~ ^([a-zA-Z0-9_]+)-(.+)$ ]]; then
      lang="${match[1]}"
      ver="${match[2]}"
      [[ "$lang" == "node" ]] && lang="nodejs"
      [[ "$lang" == "go" ]] && lang="golang"
      echo "$lang $ver" >>"$TOOL_VERSIONS"
    else
      lang="$req"
      [[ "$lang" == "node" ]] && lang="nodejs"
      [[ "$lang" == "go" ]] && lang="golang"
      echo "$lang latest" >>"$TOOL_VERSIONS"
    fi
  done

  if [[ -s "$TOOL_VERSIONS" ]]; then
    sort -u "$TOOL_VERSIONS" -o "$TOOL_VERSIONS"
  fi
fi

echo "==> Starting YADRLite Setup (OS: $OS_LOWER, Version: $CURRENT_VERSION)"

if [[ "$MIGRATE" == "1" && "$INSTALLED_VERSION" != "$CURRENT_VERSION" ]]; then
  echo "==> Migration requested: $INSTALLED_VERSION -> $CURRENT_VERSION"
  for mig_dir in "$SCRIPT_DIR/setup/migrations"/v*(/N); do
    mig_ver="${${mig_dir:t}#v}"
    if version_gt "$mig_ver" "$INSTALLED_VERSION" || [[ "$mig_ver" == "$CURRENT_VERSION" && "$INSTALLED_VERSION" == "1.0.0" ]]; then
      if [[ -f "$mig_dir/pre.zsh" ]]; then
        source "$mig_dir/pre.zsh"
      fi
    fi
  done
fi

run_hook() {
  local hook_path="$1"
  if [[ -f "$hook_path" ]]; then
    echo "==> Running hook: $(basename "$hook_path")"
    if ! source "$hook_path"; then
      echo "Error: Hook $(basename "$hook_path") failed with exit code $?. Aborting setup."
      exit 1
    fi
  fi
}

run_brewfile() {
  local brewfile_path="$1"
  if [[ -f "$brewfile_path" ]]; then
    echo "==> Installing packages from $(basename "$brewfile_path")"
    if ! brew bundle --file="$brewfile_path"; then
      echo "Error: Failed to install packages from $(basename "$brewfile_path"). Aborting setup."
      exit 1
    fi
  fi
}

# 1. Core global setup
run_hook "$SCRIPT_DIR/setup/hooks/pre/core.zsh"
run_brewfile "$SCRIPT_DIR/brewfiles/global-taps.Brewfile"
run_brewfile "$SCRIPT_DIR/brewfiles/global.Brewfile"

# 2. OS-specific setup
run_hook "$SCRIPT_DIR/setup/hooks/pre/${OS_LOWER}.zsh"
run_brewfile "$SCRIPT_DIR/brewfiles/${OS_LOWER}-taps.Brewfile"
run_brewfile "$SCRIPT_DIR/brewfiles/${OS_LOWER}.Brewfile"

# 3. Feature modules
for feature in $FEATURES; do
  if [[ "$feature" != "$OS_LOWER" ]]; then
    run_hook "$SCRIPT_DIR/setup/hooks/pre/${feature}.zsh"
    run_brewfile "$SCRIPT_DIR/brewfiles/${feature}-taps.Brewfile"
    run_brewfile "$SCRIPT_DIR/brewfiles/${feature}.Brewfile"
    run_hook "$SCRIPT_DIR/setup/hooks/post/${feature}.zsh"
  fi
done

# 4. Finalize
run_hook "$SCRIPT_DIR/setup/hooks/post/${OS_LOWER}.zsh"
run_hook "$SCRIPT_DIR/setup/hooks/post/core.zsh"

if [[ "$MIGRATE" == "1" && "$INSTALLED_VERSION" != "$CURRENT_VERSION" ]]; then
  for mig_dir in "$SCRIPT_DIR/setup/migrations"/v*(/N); do
    mig_ver="${${mig_dir:t}#v}"
    if version_gt "$mig_ver" "$INSTALLED_VERSION" || [[ "$mig_ver" == "$CURRENT_VERSION" && "$INSTALLED_VERSION" == "1.0.0" ]]; then
      if [[ -f "$mig_dir/post.zsh" ]]; then
        source "$mig_dir/post.zsh"
      fi
    fi
  done
  echo "$CURRENT_VERSION" >"$YADR_DIR/.installed_version"
  echo "==> Migration complete!"
fi

echo "==> Setup complete!"
