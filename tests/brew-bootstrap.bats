#!/usr/bin/env bats
# Tests for brew-bootstrap.sh

setup() {
    # Create test script directory
    SCRIPT_DIR="$BATS_TEST_TMPDIR/scripts"
    mkdir -p "$SCRIPT_DIR"
    
    # Copy script to test location
    cp "$BATS_TEST_DIRNAME/../scripts/brew-bootstrap.sh" "$SCRIPT_DIR/"
}

@test "script exists and is executable" {
    [ -f "$SCRIPT_DIR/brew-bootstrap.sh" ]
    [ -x "$SCRIPT_DIR/brew-bootstrap.sh" ]
}

@test "script has proper syntax" {
    # Test basic syntax by parsing the script
    run bash -n "$SCRIPT_DIR/brew-bootstrap.sh"
    [ "$status" -eq 0 ]
}

@test "script handles unknown flags" {
    run "$SCRIPT_DIR/brew-bootstrap.sh" --invalid-flag
    [ "$status" -eq 1 ]
    [[ "$output" == *"Unknown flag"* ]]
}
