# Changelog

All notable changes to this project will be documented in this file.


## [Unreleased]


### Bug Fixes

- *(macos)* Improve ARM64 support and fix setup script

- Correct gitleaks url and starship installation flag

- *(zsh)* Prevent nomatch errors on empty globs

- Address PR feedback for Zsh nullglob, arrays, and linting

- *(asdf)* Filter out comments and empty lines when parsing .tool-versions

- *(brew)* Remove unsupported --no-lock flag and resolve dynamic path

- *(macos)* Correctly tap and symlink sketchybar to prevent stale config files

- *(macos)* Orchestrate borders via aerospace and symlink config

- *(setup)* Resolve syntax error and update Makefile for zsh rename

- *(setup)* Correctly parse --force argument in router

- *(macos)* Resolve sketchybar installation error

- *(core)* Establish Homebrew Node as the source of truth

- *(starship)* Revert to original maintainer aesthetic and disable rogue keyboard remapping

- Resolve TOML syntax error and homebrew package name

- *(starship)* Resolve TOML parse error correctly

- *(langs)* Remove nodejs from 'all' ASDF default installations

- *(langs)* Add Homebrew C-library dependencies for ASDF runtime compilation

- *(ci)* Repair broken workflow YAML that silently prevented CI from ever running

- *(ci)* Use bash-compatible zsh-file discovery in the syntax-check step

- *(ci)* Install Homebrew on the Linux CI runner; fix cliff.toml template syntax

- Address PR review findings from Amazon Q, Codex, and Gemini


### Documentation

- Update CLAUDE.md and README.md to reflect new install.sh and setup.sh architecture

- Generate and add VHS terminal recording to README

- Refactor README and move component guides to docs directory

- Update terminal recording to show new ASDF arguments in help output

- Update CLAUDE.md to document ASDF and rolling migrations

- Update README.md to prominently feature new uninstall and upgrade/migrate commands

- Fix remaining setup.sh references to setup.zsh

- Establish golden path architecture and revert CLI binaries back to Homebrew


### Features

- Extract destructive keyboard remapping into explicit opt-in command

- Extract destructive keyboard remapping into explicit opt-in command

- Implement scalable feature hooks and Brewfile bundles

- Add ASDF universal language manager with legacy fallback

- Add zero-downtime migration pipeline and automated changelog

- Add dedicated uninstall.sh, enforce OS overrides, and rename setup.zsh

- Manage standard CLI tools and PHP entirely through ASDF

- Treat fonts as dynamic dependencies for Starship

- Implement unified --with-tiling-wm and clean up router flags

- Replace hard configuration copies with safe symlinking and enforce --force flag

- Add robust terminal fallbacks to base installation

- Enrich global toolkit with modern UNIX utilities

- Empower terminal environment with native tools and rich prompt UI

- *(starship)* Inject advanced system monitoring and git state modules

- *(starship)* Add gcloud and azure cloud context modules

- *(starship)* Refactor prompt to bracketed style for maximum info density


### Miscellaneous Tasks

- Add community health files and fix POSIX linting

- Add empty setup/hooks/pre directory with .gitkeep to enforce modular structure

- Remove old tools.sh and update paths for ASDF and NVM integration

- Update generated artifacts (changelog, demo gif) [skip ci]


### Refactoring

- Simplify tools and update scripts via Homebrew

- *(brew)* Isolate languages from global.Brewfile

- *(core)* Elevate starship and its required font to global defaults

- *(macos)* Move hack nerd font to native macos brewfile

- Formally drop legacy Bash support to centralize strictly on Zsh

- *(tools)* Remove highly-opinionated global npm package installations


### Testing

- Add ShellSpec BDD testing, Linting, and Makefile

- Restore fully passing BDD spec suite


### Ci

- Add VHS terminal recording generator for PRs

- Merge changelog generator into unified artifact workflow

- Pin GitHub Actions to strict commit SHAs for supply chain security


