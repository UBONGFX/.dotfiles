# tests/set_shell.bats
#!/usr/bin/env bats

setup() {
  # Create a temp HOME and bin for stubs
  export HOME="$BATS_TEST_TMPDIR/home"
  mkdir -p "$HOME/.dotfiles/scripts" "$BATS_TEST_TMPDIR/bin"
  cp scripts/set_shell.sh "$HOME/.dotfiles/scripts/"
  chmod +x "$HOME/.dotfiles/scripts/set_shell.sh"

  # Prepend our stub bin to PATH
  export PATH="$BATS_TEST_TMPDIR/bin:$PATH"
  # Default: real /etc/shells file in temp
  export SHELL="/bin/bash"
  cp /etc/shells "$BATS_TEST_TMPDIR/shells"
}

teardown() {
  rm -rf "$BATS_TEST_TMPDIR"
}

# 1. No Homebrew in PATH
@test "No Homebrew in PATH" {
  # Ensure brew not found
  mv "$(command -v brew)" /tmp/brew.tmp 2>/dev/null || true

  run bash "$HOME/.dotfiles/scripts/set_shell.sh"
  [ "$status" -eq 1 ]
  [[ "$output" == *"Homebrew not found"* ]]

  # restore brew if existed
  mv /tmp/brew.tmp "$(command -v brew)" 2>/dev/null || true
}

# 2. Brew‑Zsh missing
@test "Brew prefix present but Zsh missing" {
  # Setup: simulate brew --prefix, no $prefix/bin/zsh
  # Act: run set_shell.sh
  # Assert: script exits error “Zsh not found”
}

# 3. Already running brew‑Zsh
@test "Already running brew‑installed Zsh" {
  # Setup: set SHELL to brew Zsh path
  # Act: run set_shell.sh
  # Assert: prints skip message, exit 0
}

# 4. Needs registration
@test "Register brew Zsh and change shell" {
  # Setup: brew zsh exists, not in /etc/shells
  # Act: run set_shell.sh
  # Assert: /etc/shells appended, chsh called
}

# 5. Already registered, needs change
@test "Already registered brew Zsh, change shell" {
  # Setup: brew Zsh in /etc/shells, login shell != brew Zsh
  # Act: run set_shell.sh
  # Assert: skips registration, chsh called
}

# 6. chsh failure
@test "chsh returns non-zero" {
  # Setup: stub chsh to fail
  # Act: run set_shell.sh
  # Assert: prints manual instruction, exit 1
}