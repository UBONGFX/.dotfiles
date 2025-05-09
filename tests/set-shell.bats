#!/usr/bin/env bats

setup() {
  # Create a temp HOME and bin for stubs
  export HOME="$BATS_TEST_TMPDIR/home"
  mkdir -p "$HOME/.dotfiles/scripts" "$BATS_TEST_TMPDIR/bin"
  cp scripts/set-shell.sh "$HOME/.dotfiles/scripts/"
  chmod +x "$HOME/.dotfiles/scripts/set-shell.sh"

  # Prepend our stub bin to PATH
  export PATH="$BATS_TEST_TMPDIR/bin:$PATH"
  # Default: real /etc/shells file in temp
  export SHELL="/bin/bash"
  cp /etc/shells "$BATS_TEST_TMPDIR/shells"
}

teardown() {
  rm -rf "$BATS_TEST_TMPDIR"
}

@test "dummy" {
  run true
  [ "$status" -eq 0 ]
}

@test "No Homebrew in PATH" {
  # Capture the real brew location
  original_brew="$(command -v brew || true)"

  # Ensure brew not found
  if [ -n "$original_brew" ]; then
    mv "$original_brew" /tmp/brew.tmp
  fi

  run bash "$HOME/.dotfiles/scripts/set-shell.sh"
  [ "$status" -eq 1 ]
  [[ "$output" == *"Homebrew not found"* ]]

  # Restore brew if we moved it
  if [ -n "$original_brew" ] && [ -f /tmp/brew.tmp ]; then
    mv /tmp/brew.tmp "$original_brew"
  fi
}

# 2. Brew‑Zsh missing
@test "Brew prefix present but Zsh missing" {
  # Stub brew and prefix
  cat > "$BATS_TEST_TMPDIR/bin/brew" <<'EOF'
#!/usr/bin/env bash
if [ "$1" = "--prefix" ]; then
  echo "/fakebrew"
else
  /usr/bin/brew "$@"
fi
EOF
  mkdir -p /fakebrew/bin
  chmod +x "$BATS_TEST_TMPDIR/bin/brew"

  run bash "$HOME/.dotfiles/scripts/set-shell.sh"
  [ "$status" -eq 1 ]
  [[ "$output" == *"Zsh not found at /fakebrew/bin/zsh"* ]]
}

# # 3. Already running brew‑installed Zsh
# @test "Already running brew‑installed Zsh" {
#   # Stub brew to point at /usr
#   cat > "$BATS_TEST_TMPDIR/bin/brew" <<'EOF'
# #!/usr/bin/env bash
# if [ "$1" = "--prefix" ]; then
#   echo "/usr"
# else
#   /usr/bin/brew "$@"
# fi
# EOF
#   chmod +x "$BATS_TEST_TMPDIR/bin/brew"

#   zsh_path="/usr/bin/zsh"
#   run env SHELL="$zsh_path" bash "$HOME/.dotfiles/scripts/set-shell.sh"

#   [ "$status" -eq 0 ]
#   [[ "$output" == *"Already running brew-installed Zsh"* ]]
# }
