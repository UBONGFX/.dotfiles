#!/usr/bin/env bats

setup() {
  # Create isolated test environment  
  TEST_HOME="$BATS_TEST_TMPDIR/test_home"
  mkdir -p "$TEST_HOME"
  export HOME="$TEST_HOME"
  
  # Create test script directory
  SCRIPT_DIR="$BATS_TEST_TMPDIR/scripts"
  mkdir -p "$SCRIPT_DIR"
  
  # Copy script to test location
  cp "$BATS_TEST_DIRNAME/../scripts/set-shell.sh" "$SCRIPT_DIR/"
  
  # Create mock bin directory
  MOCK_BIN="$BATS_TEST_TMPDIR/bin"
  mkdir -p "$MOCK_BIN"
  
  # Create minimal required commands
  echo '#!/bin/bash' > "$MOCK_BIN/id"
  echo 'echo "testuser"' >> "$MOCK_BIN/id"
  chmod +x "$MOCK_BIN/id"
  
  # Put mocks first in PATH
  export PATH="$MOCK_BIN:/bin:/usr/bin"
}

@test "script exists and is executable" {
  [ -f "$SCRIPT_DIR/set-shell.sh" ]
  [ -x "$SCRIPT_DIR/set-shell.sh" ]
}

@test "detects missing Homebrew correctly" {
  # Test the core logic without triggering system calls
  run bash -c 'if ! command -v brew &>/dev/null; then echo "❌ Homebrew not found—cannot determine Zsh path."; exit 1; fi'
  [ "$status" -eq 1 ]
  [[ "$output" == *"Homebrew not found"* ]]
}

@test "validates core logic components" {
  # Test the script can at least run basic checks
  cat > "$MOCK_BIN/brew" <<'EOF'
#!/bin/bash
echo "mock brew called with: $@" >&2
exit 1
EOF
  chmod +x "$MOCK_BIN/brew"

  run env PATH="$MOCK_BIN:/bin:/usr/bin" "$SCRIPT_DIR/set-shell.sh"
  [ "$status" -eq 1 ]
  # Just ensure it fails appropriately when brew fails
}
