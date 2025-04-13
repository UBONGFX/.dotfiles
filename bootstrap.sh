#!/bin/bash
# This script will back up your existing dotfiles 🗄️
# and create symbolic links 🔗 to your dotfiles repository.

DOTFILES_DIR="$HOME/.dotfiles"

# Prepare a backup directory variable with a timestamp for any existing files
BACKUP_DIR="$DOTFILES_DIR/_backup_$(date +%Y%m%d%H%M%S)"

echo "🔧 Bootstrapping dotfiles from $DOTFILES_DIR..."

# Parallel arrays: one for target files, one for source files
TARGETS=(
    ".zsh"
    ".zshrc"
    ".config/starship.toml"
    ".config/ghostty/config"
)

SOURCES=(
    "$DOTFILES_DIR/zsh"
    "$DOTFILES_DIR/zshrc"
    "$DOTFILES_DIR/config/starship.toml"
    "$DOTFILES_DIR/config/ghostty/config"
)

# Loop over each file and create/update symlinks
for i in "${!TARGETS[@]}"; do
  TARGET="${TARGETS[$i]}"
  SOURCE="${SOURCES[$i]}"
  DEST="$HOME/$TARGET"

  # Automatically create the target directory if it doesn't exist.
  DEST_DIR=$(dirname "$DEST")
  mkdir -p "$DEST_DIR"

  # If the target file/directory exists and isn't already a symlink, back it up first.
  if [ -e "$DEST" ] && [ ! -L "$DEST" ]; then
    # Create the backup directory if it hasn't been created yet.
    if [ ! -d "$BACKUP_DIR" ]; then
      mkdir -p "$BACKUP_DIR"
    fi
    echo "🗄️  Backing up existing $DEST to $BACKUP_DIR"
    mv "$DEST" "$BACKUP_DIR/"
  fi

  # Create or update the symbolic link.
  ln -sf "$SOURCE" "$DEST"
  echo "✅ Linked $SOURCE -> $DEST"
done

echo "🎉 Dotfiles bootstrapping complete!"