# tests/bootstrap.bats
#!/usr/bin/env bats

setup() {
  # Prepare an isolated HOME
  export HOME="$BATS_TEST_TMPDIR/home"
  mkdir -p "$HOME/.dotfiles/scripts"
  cp scripts/bootstrap.sh "$HOME/.dotfiles/scripts/bootstrap.sh"
  chmod +x "$HOME/.dotfiles/scripts/bootstrap.sh"
}

@test "Normal mode, fresh home" {
  # Act
  run bash "$HOME/.dotfiles/scripts/bootstrap.sh"
  [ "$status" -eq 0 ] || fail "❌ Script exited with status $status"

  # Assert each target is now a symlink
  for target in .zsh .zshrc .gitconfig .gitignore_global .config/nvim .config/starship.toml .config/ghostty/config; do
    [ -L "$HOME/$target" ] \
      || fail "❌ $HOME/$target is not a symlink"
  done

  # Assert no backup directory was ever created
  ! ls "$HOME/.dotfiles/_backup_"* 2>/dev/null \
    || fail "❌ Unexpected backup directory found"
}

@test "Normal mode, existing file" {
  # Setup
  mkdir -p "$HOME/.config/ghostty"
  echo "ORIGINAL" > "$HOME/.config/ghostty/config"

  # Act
  run bash "$HOME/.dotfiles/scripts/bootstrap.sh"
  [ "$status" -eq 0 ] || fail "❌ Script exited with status $status"

  # Assert: a backup directory was created
  backup_dir=$(ls -d "$HOME/.dotfiles/_backup_"* 2>/dev/null)
  [ -d "$backup_dir" ] \
    || fail "❌ No backup directory found"

  # Assert: the original file was moved into the backup
  [ -f "$backup_dir/config" ] \
    || fail "❌ Original file not found in backup"

  # Assert: a symlink now exists at the target
  [ -L "$HOME/.config/ghostty/config" ] \
    || fail "❌ Expected a symlink at the target"

  # Assert: the symlink points to the repo source
  target="$(readlink "$HOME/.config/ghostty/config")"
  [ "$target" = "$HOME/.dotfiles/config/ghostty/config" ] \
    || fail "❌ Symlink points to '$target' instead of the repo path"
}

@test "Normal mode, existing symlink" {
  # Setup
  mkdir -p "$HOME/.config/ghostty"
  ln -s "/tmp/old-target" "$HOME/.config/ghostty/config"

  # Act
  run bash "$HOME/.dotfiles/scripts/bootstrap.sh"
  [ "$status" -eq 0 ] || fail "❌ Script exited with status $status"

  # Assert: a symlink exists at the target
  [ -L "$HOME/.config/ghostty/config" ] \
    || fail "❌ Expected a symlink at the target"

  # Assert: it now points into the dotfiles repo
  target="$(readlink "$HOME/.config/ghostty/config")"
  [ "$target" = "$HOME/.dotfiles/config/ghostty/config" ] \
    || fail "❌ Symlink points to '$target' instead of '$HOME/.dotfiles/config/ghostty/config'"

  # Assert: no backup folder was created for a symlink
  ! ls "$HOME/.dotfiles/_backup_"* 2>/dev/null \
    || fail "❌ Unexpected backup directory created for a symlink"
}

@test "Soft mode, existing file" {
  # Setup
  mkdir -p "$HOME/.config/ghostty"
  echo "KEEPME" > "$HOME/.config/ghostty/config"

  # Act
  run bash "$HOME/.dotfiles/scripts/bootstrap.sh" --soft
  [ "$status" -eq 0 ] || fail "❌ Script exited with status $status"

  # Assert: original file still exists and content unchanged
  [ -f "$HOME/.config/ghostty/config" ] \
    || fail "❌ Expected file to remain"
  [ "$(cat "$HOME/.config/ghostty/config")" = "KEEPME" ] \
    || fail "❌ Content was altered"

  # Assert: no backup directory created
  ! ls "$HOME/.dotfiles/_backup_"* &>/dev/null \
    || fail "❌ Unexpected backup folder"

  # Assert: no symlink created
  [ ! -L "$HOME/.config/ghostty/config" ] \
    || fail "❌ Symlink should not be created in soft mode"
}

@test "Soft mode, no existing file" {
  # Act
  run bash "$HOME/.dotfiles/scripts/bootstrap.sh" --soft
  [ "$status" -eq 0 ] || fail "❌ Script failed in soft mode on clean home"

  # Assert: each expected target is now a symlink
  for target in \
    .zsh \
    .zshrc \
    .gitconfig \
    .gitignore_global \
    .config/nvim \
    .config/starship.toml \
    .config/ghostty/config; do

    [ -L "$HOME/$target" ] \
      || fail "❌ Expected a symlink at $HOME/$target, but none found"
  done
}