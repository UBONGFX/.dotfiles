#!/usr/bin/env bats
# Tests for brew-bootstrap.sh

setup() {
    # Create test script directory
    SCRIPT_DIR="$BATS_TEST_TMPDIR/scripts"
    mkdir -p "$SCRIPT_DIR"
    
    # Copy script to test location
    cp "$BATS_TEST_DIRNAME/../scripts/brew-bootstrap.sh" "$SCRIPT_DIR/"
    
    # Create mock bin directory
    MOCK_BIN="$BATS_TEST_TMPDIR/bin"
    mkdir -p "$MOCK_BIN"
    
    # Create mock brew command
    cat > "$MOCK_BIN/brew" <<'EOF'
#!/bin/bash
if [ "$1" = "--version" ]; then
  echo "Homebrew 4.6.0"
elif [ "$1" = "bundle" ]; then
  echo "Mock: brew bundle $@"
else
  echo "Mock: brew $@"
fi
EOF
    chmod +x "$MOCK_BIN/brew"
    
    # Put mocks first in PATH
    export PATH="$MOCK_BIN:/bin:/usr/bin"
}

@test "script exists and is executable" {
    [ -f "$SCRIPT_DIR/brew-bootstrap.sh" ]
    [ -x "$SCRIPT_DIR/brew-bootstrap.sh" ]
}

@test "script has proper syntax" {
    run bash -n "$SCRIPT_DIR/brew-bootstrap.sh"
    [ "$status" -eq 0 ]
}

@test "fails when Homebrew not installed" {
    # Remove brew mock
    rm -f "$MOCK_BIN/brew"
    
    run env PATH="/bin:/usr/bin" "$SCRIPT_DIR/brew-bootstrap.sh"
    [ "$status" -eq 1 ]
    [[ "$output" == *"Homebrew not found"* ]]
    [[ "$output" == *"curl -fsSL"* ]]
}

@test "handles unknown flags correctly" {
    run "$SCRIPT_DIR/brew-bootstrap.sh" --invalid-flag
    [ "$status" -eq 1 ]
    [[ "$output" == *"Unknown flag"* ]]
    [[ "$output" == *"Usage:"* ]]
}
