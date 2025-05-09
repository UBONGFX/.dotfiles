# tests/brew-bootstrap.bats
#!/usr/bin/env bats

setup() {
  # 1) Isolate HOME
  export HOME="$BATS_TMPDIR/fakehome"
  mkdir -p "$HOME/.dotfiles/brewfiles"

  # 2) Copy & make executable the real script under test
  mkdir -p "$HOME/.dotfiles/scripts"
  cp scripts/brew-bootstrap.sh "$HOME/.dotfiles/scripts/brew-bootstrap.sh"
  chmod +x "$HOME/.dotfiles/scripts/brew-bootstrap.sh"

  # 3) Mock brew & curl so nothing external runs
  mockbin="$BATS_TMPDIR/mockbin"
  mkdir -p "$mockbin"
  cat >"$mockbin/brew" <<'EOF'
#!/usr/bin/env bash
# mock brew: just echo its arguments
echo "[MOCK BREW] $*"
EOF
  cat >"$mockbin/curl" <<'EOF'
#!/usr/bin/env bash
# mock curl: do nothing
exit 0
EOF
  chmod +x "$mockbin/"{brew,curl}
  export PATH="$mockbin:$PATH"
}

teardown() {
  rm -rf "$HOME"
}

@test "Unknown flag exits with error" {
  run bash "$HOME/.dotfiles/scripts/brew-bootstrap.sh" --foo
  [ "$status" -ne 0 ]
  [[ "$output" =~ "❌ Unknown flag: --foo" ]]
  [[ "$output" =~ "Usage:" ]]
}

@test "Default mode on Linux with no brewfiles present" {
  run bash "$HOME/.dotfiles/scripts/brew-bootstrap.sh"
  [ "$status" -eq 0 ]
  [[ "$output" =~ "▶ Installation mode: all" ]]
  [[ "$output" =~ "🖥️ Detected Linux — running core formulae only" ]]
  [[ "$output" =~ "⚠️ Brewfile not found: $HOME/.dotfiles/brewfiles/brewfile-base — skipping" ]]
}

@test "Installs from existing brewfile-base" {
  # create a dummy brewfile only for this test
  touch "$HOME/.dotfiles/brewfiles/brewfile-base"
  brewfile="$HOME/.dotfiles/brewfiles/brewfile-base"

  run bash "$HOME/.dotfiles/scripts/brew-bootstrap.sh" --base
  [ "$status" -eq 0 ]
  [[ "$output" =~ "▶ Installation mode: base" ]]
  [[ "$output" =~ "📦 Installing from $brewfile" ]]
  # Verify the mock brew bundle invocation
  [[ "$output" =~ \[MOCK\ BREW\]\ bundle\ --file=$brewfile ]]
  [[ "$output" =~ "✅ Finished $brewfile" ]]
}

@test "--office and --private behave like --all on Linux" {
  run bash "$HOME/.dotfiles/scripts/brew-bootstrap.sh" --office
  [ "$status" -eq 0 ]
  [[ "$output" =~ "▶ Installation mode: office" ]]
  [[ "$output" =~ "🖥️ Detected Linux — running core formulae only" ]]

  run bash "$HOME/.dotfiles/scripts/brew-bootstrap.sh" --private
  [ "$status" -eq 0 ]
  [[ "$output" =~ "▶ Installation mode: private" ]]
  [[ "$output" =~ "🖥️ Detected Linux — running core formulae only" ]]
}
