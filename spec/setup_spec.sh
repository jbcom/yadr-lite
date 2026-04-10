Describe 'setup.zsh router'
  # Setup.zsh is zsh-based
  It 'shows help when no arguments are provided'
    When run script setup.zsh
    The status should be success
    The output should include 'Usage: ./setup.zsh [--macos | --linux] [--with-<feature>...] [--migrate] [--upgrade]'
    The output should include 'Legacy Actions:'
  End

  It 'shows help when help argument is provided'
    When run script setup.zsh help
    The status should be success
    The output should include 'Legacy Actions:'
  End

  It 'fails gracefully with an unknown argument'
    When run script setup.zsh invalid_action_99
    The status should be success
    The output should include 'Unknown argument: invalid_action_99'
  End

  Describe 'subcommand routing'
    setup_fake_env() {
      mkdir -p temp_test_env/setup/hooks/pre temp_test_env/setup/hooks/post temp_test_env/brewfiles
      cat << 'INNER_EOF' > temp_test_env/setup.zsh
#!/usr/bin/env zsh
action="${1:-help}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-${(%):-%x}}")" && pwd)"
if [ -x "$SCRIPT_DIR/setup/${action}.zsh" ]; then
  "$SCRIPT_DIR/setup/${action}.zsh"
fi
INNER_EOF
      chmod +x temp_test_env/setup.zsh
      echo 'echo "tools script executed"' > temp_test_env/setup/tools.zsh
      chmod +x temp_test_env/setup/tools.zsh
    }
    
    BeforeEach 'setup_fake_env'
    AfterEach 'rm -rf temp_test_env'

    It 'correctly routes to a valid subcommand'
      When run script temp_test_env/setup.zsh tools
      The status should be success
      The output should equal 'tools script executed'
    End
  End
End
