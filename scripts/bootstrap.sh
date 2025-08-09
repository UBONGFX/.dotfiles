#!/bin/bash
# Bootstraps your dotfiles repository:
#   • Backs up existing non-symlink dotfiles 🗄️
#   • Creates or updates symbolic links 🔗 from $HOME to your repo
#   • Supports “soft” mode (--soft): preserves existing files without backing up or linking 🔕

set -euo pipefail

# usage: bootstrap.sh [--soft]
SOFT_MODE=false
if [[ "${1:-}" == "--soft" ]]; then
  SOFT_MODE=true
  echo "⚠️  Running in SOFT mode: existing files will be left in place."
fi

DOTFILES_DIR="$HOME/.dotfiles"
BACKUP_DIR="$DOTFILES_DIR/_backup_$(date +%Y%m%d%H%M%S)"

echo -e "\n🔧 Bootstrapping dotfiles from $DOTFILES_DIR...\n"

TARGETS=(
    ".zsh"
    ".zshrc"
    ".gitconfig"
    ".gitignore_global"
    ".config/nvim"
    ".config/starship.toml"
    ".config/ghostty/config"
)

SOURCES=(
    "$DOTFILES_DIR/zsh"
    "$DOTFILES_DIR/zshrc"
    "$DOTFILES_DIR/.gitconfig"
    "$DOTFILES_DIR/gitignore_global"
    "$DOTFILES_DIR/config/nvim"
    "$DOTFILES_DIR/config/starship.toml"
    "$DOTFILES_DIR/config/ghostty/config"
)

# Loop over each file and create/update symlinks
for i in "${!TARGETS[@]}"; do
  TARGET="${TARGETS[$i]}"
  SOURCE="${SOURCES[$i]}"
  DEST="$HOME/$TARGET"

  # Ensure parent directory exists
  mkdir -p "$(dirname "$DEST")"

  # if soft mode and something already exists, skip it entirely
  if $SOFT_MODE && [ -e "$DEST" ]; then
    echo "🔕 Soft mode: keeping existing $DEST"
    continue
  fi

  # If the target file/directory exists and isn't already a symlink, back it up first.
  if [ -e "$DEST" ] && [ ! -L "$DEST" ]; then
    if [ ! -d "$BACKUP_DIR" ]; then
      mkdir -p "$BACKUP_DIR"
    fi

    echo "🗄️ Backing up existing $DEST to $BACKUP_DIR"
    mv "$DEST" "$BACKUP_DIR/"
  fi

  if [ -d "$SOURCE" ] && [ -L "$DEST" ]; then
    echo "🗑 Removing existing  $DEST"
    rm "$DEST"
  fi

  # Create or update the symbolic link.
  ln -sf "$SOURCE" "$DEST"
  echo "✅ Linked $SOURCE -> $DEST"
done

echo -e "\n🎉 Dotfiles bootstrapping complete!"
