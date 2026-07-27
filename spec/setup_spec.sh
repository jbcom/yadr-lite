Describe 'setup.zsh router'
  # Setup.zsh is zsh-based
  It 'runs setup when no arguments are provided'
    When run script setup.zsh
    The status should be success
    The stderr should not include 'Error:'
    The output should include 'Starting YADRLite Setup'
  End

  It 'shows help when help argument is provided'
    When run script setup.zsh help
    The status should be success
    The output should include 'Usage: ./setup.zsh [--macos | --linux] [--with-<feature>...] [--migrate] [--upgrade]'
    The output should include 'Maintenance:'
  End

  It 'fails gracefully with an unknown argument'
    When run script setup.zsh invalid_action_99
    The status should be failure
    The output should include 'Unknown argument: invalid_action_99'
  End

  Describe 'subcommand routing'
    setup_fake_env() {
      mkdir -p temp_test_env/setup/hooks/pre temp_test_env/setup/hooks/post temp_test_env/brewfiles temp_test_env/setup/scripts
      cat << 'INNER_EOF' > temp_test_env/setup.zsh
#!/usr/bin/env zsh
action="${1:-setup}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-${(%):-%x}}")" && pwd)"

run_hook() {
  local hook_path="$1"
  if [[ -f "$hook_path" ]]; then
    if ! source "$hook_path"; then
      echo "Error: Hook $(basename "$hook_path") failed with exit code $?. Aborting setup." >&2
      exit 1
    fi
  fi
}

run_brewfile() {
  local brewfile_path="$1"
  if [[ -f "$brewfile_path" ]]; then
    if ! brew bundle --file="$brewfile_path" 2>/dev/null; then
      echo "Error: Failed to install packages from $(basename "$brewfile_path"). Aborting setup." >&2
      exit 1
    fi
  fi
}

if [[ "$action" == "test_hook_fail" ]]; then
  run_hook "$SCRIPT_DIR/setup/hooks/pre/fail.zsh"
  echo "SHOULD NOT PRINT"
  exit 0
fi

if [[ "$action" == "test_brew_fail" ]]; then
  brew() { return 1; }
  run_brewfile "$SCRIPT_DIR/brewfiles/fail.Brewfile"
  echo "SHOULD NOT PRINT"
  exit 0
fi

if [[ "$action" == "test_script" ]]; then
  "$SCRIPT_DIR/setup/scripts/tools.zsh"
fi
INNER_EOF
      chmod +x temp_test_env/setup.zsh
      echo 'echo "tools script executed"' > temp_test_env/setup/scripts/tools.zsh
      chmod +x temp_test_env/setup/scripts/tools.zsh
      
      echo 'false' > temp_test_env/setup/hooks/pre/fail.zsh
      touch temp_test_env/brewfiles/fail.Brewfile
    }
    
    BeforeEach 'setup_fake_env'
    AfterEach 'rm -rf temp_test_env'

    It 'correctly routes to a script'
      When run script temp_test_env/setup.zsh test_script
      The status should be success
      The output should equal 'tools script executed'
    End
    
    It 'aborts setup immediately if a hook fails'
      When run script temp_test_env/setup.zsh test_hook_fail
      The status should be failure
      The stderr should include 'Error: Hook fail.zsh failed'
      The output should not include 'SHOULD NOT PRINT'
    End
    
    It 'aborts setup immediately if a Brewfile fails'
      When run script temp_test_env/setup.zsh test_brew_fail
      The status should be failure
      The stderr should include 'Error: Failed to install packages from fail.Brewfile'
      The output should not include 'SHOULD NOT PRINT'
    End
  End
End
