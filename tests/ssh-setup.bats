#!/usr/bin/env bats

setup() {
  # Prepare an isolated HOME
  export HOME="$BATS_TEST_TMPDIR/home"
  mkdir -p "$HOME/.dotfiles/scripts"
  mkdir -p "$HOME/.dotfiles/config/ssh"
  
  # Copy the script and config
  cp scripts/ssh-setup.sh "$HOME/.dotfiles/scripts/ssh-setup.sh"
  cp config/ssh/config "$HOME/.dotfiles/config/ssh/config"
  chmod +x "$HOME/.dotfiles/scripts/ssh-setup.sh"
  
  # Mock hostname and USER for consistent testing
  export USER="testuser"
}

teardown() {
  # Clean up any SSH agent processes started during tests
  if [[ -n "${SSH_AGENT_PID:-}" ]]; then
    kill "$SSH_AGENT_PID" 2>/dev/null || true
  fi
}

@test "Fresh setup: creates SSH directory, config, and keys" {
  # Act
  run bash "$HOME/.dotfiles/scripts/ssh-setup.sh"
  
  # Assert script succeeded
  [ "$status" -eq 0 ]
  
  # Assert SSH directory created with correct permissions
  [ -d "$HOME/.ssh" ]
  [ "$(stat -c %a "$HOME/.ssh" 2>/dev/null || stat -f %Mp%Lp "$HOME/.ssh" | tail -c 4)" = "700" ]
  
  # Assert config file created with correct permissions
  [ -f "$HOME/.ssh/config" ]
  [ "$(stat -c %a "$HOME/.ssh/config" 2>/dev/null || stat -f %Mp%Lp "$HOME/.ssh/config" | tail -c 4)" = "600" ]
  
  # Assert SSH keys created with correct permissions
  [ -f "$HOME/.ssh/id_ed25519" ]
  [ -f "$HOME/.ssh/id_ed25519.pub" ]
  [ "$(stat -c %a "$HOME/.ssh/id_ed25519" 2>/dev/null || stat -f %Mp%Lp "$HOME/.ssh/id_ed25519" | tail -c 4)" = "600" ]
  [ "$(stat -c %a "$HOME/.ssh/id_ed25519.pub" 2>/dev/null || stat -f %Mp%Lp "$HOME/.ssh/id_ed25519.pub" | tail -c 4)" = "644" ]
  
  # Assert config content is from dotfiles
  grep -q "# SSH Configuration" "$HOME/.ssh/config"
  grep -q "Host github.com" "$HOME/.ssh/config"
}

@test "Already configured: shows status and exits gracefully" {
  # Setup - create existing SSH setup
  mkdir -p "$HOME/.ssh"
  chmod 700 "$HOME/.ssh"
  cp "$HOME/.dotfiles/config/ssh/config" "$HOME/.ssh/config"
  chmod 600 "$HOME/.ssh/config"
  
  # Create mock SSH keys
  echo "-----BEGIN OPENSSH PRIVATE KEY-----" > "$HOME/.ssh/id_ed25519"
  echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMockKeyForTesting testuser@testhost" > "$HOME/.ssh/id_ed25519.pub"
  chmod 600 "$HOME/.ssh/id_ed25519"
  chmod 644 "$HOME/.ssh/id_ed25519.pub"
  
  # Act
  run bash "$HOME/.dotfiles/scripts/ssh-setup.sh"
  
  # Assert script succeeded
  [ "$status" -eq 0 ]
  
  # Assert output shows existing configuration
  [[ "$output" =~ "SSH is already fully configured" ]]
  [[ "$output" =~ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMockKeyForTesting" ]]
}

@test "Missing dotfiles config: fails with error" {
  # Setup - remove the dotfiles SSH config
  rm -f "$HOME/.dotfiles/config/ssh/config"
  
  # Act
  run bash "$HOME/.dotfiles/scripts/ssh-setup.sh"
  
  # Assert script failed
  [ "$status" -eq 1 ]
  
  # Assert error message shown
  [[ "$output" =~ "Error: Dotfiles SSH config not found" ]]
}

@test "Partial setup: completes missing components" {
  # Setup - create SSH directory but missing config and keys
  mkdir -p "$HOME/.ssh"
  chmod 700 "$HOME/.ssh"
  
  # Act
  run bash "$HOME/.dotfiles/scripts/ssh-setup.sh"
  
  # Assert script succeeded
  [ "$status" -eq 0 ]
  
  # Assert it found existing directory
  [[ "$output" =~ "SSH directory already exists" ]]
  
  # Assert it created missing components
  [[ "$output" =~ "SSH config copied from dotfiles" ]]
  [[ "$output" =~ "SSH keys generated successfully" ]]
}

@test "SSH key generation works correctly" {
  # Act
  run bash "$HOME/.dotfiles/scripts/ssh-setup.sh"
  
  # Assert script succeeded
  [ "$status" -eq 0 ]
  
  # Assert key files exist and are valid
  [ -f "$HOME/.ssh/id_ed25519" ]
  [ -f "$HOME/.ssh/id_ed25519.pub" ]
  
  # Assert we can read the public key (validates it's a real SSH key)
  ssh-keygen -l -f "$HOME/.ssh/id_ed25519.pub" > /dev/null
}

@test "SSH config is properly set up" {
  # Act
  run bash "$HOME/.dotfiles/scripts/ssh-setup.sh"
  
  # Assert script succeeded
  [ "$status" -eq 0 ]
  
  # Assert config file exists and contains GitHub config
  [ -f "$HOME/.ssh/config" ]
  grep -q "Host github.com" "$HOME/.ssh/config"
}

@test "Script is idempotent: safe to run multiple times" {
  # First run
  run bash "$HOME/.dotfiles/scripts/ssh-setup.sh"
  [ "$status" -eq 0 ]
  
  # Capture initial state
  initial_key=$(cat "$HOME/.ssh/id_ed25519.pub")
  
  # Second run
  run bash "$HOME/.dotfiles/scripts/ssh-setup.sh"
  [ "$status" -eq 0 ]
  
  # Assert nothing changed
  current_key=$(cat "$HOME/.ssh/id_ed25519.pub")
  [ "$initial_key" = "$current_key" ]
  
  # Assert idempotent message shown
  [[ "$output" =~ "SSH is already fully configured" ]]
}
