#!/bin/bash
# Bootstraps Homebrew and your Brewfiles:
#   • Installs Homebrew if missing (non‑interactive) 🚀🔧
#   • Sets up Homebrew environment for Linux or macOS 📝
#   • Supports modes: --base, --office, --private (default: all) ⚙️
#   • Runs `brew bundle` on each selected Brewfile 📦✅

set -euo pipefail

# Parse mode flag
mode="all"
if [[ "${1:-}" == "--base" ]]; then
  mode="base"
elif [[ "${1:-}" == "--office" ]]; then
  mode="office"
elif [[ "${1:-}" == "--private" ]]; then
  mode="private"
elif [[ "${1:-}" =~ -- ]]; then
  echo "❌ Unknown flag: $1"
  echo "Usage: $0 [--base|--office|--private]"
  exit 1
fi

echo "▶ Installation mode: $mode"

# 1. Ensure Homebrew is installed
if ! command -v brew &>/dev/null; then
  echo "🚀 Homebrew 🍺 is not installed. Installing… 🔧"

  # Install non‑interactively
  CI=1 NONINTERACTIVE=1 \
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  echo "✅ Homebrew 🍺 installed successfully! 🎉"

  # Add Homebrew to PATH
  if [[ -d "/opt/homebrew/bin" ]]; then
    export PATH="/opt/homebrew/bin:$PATH"
    echo "🍺 Added Homebrew path for Apple Silicon."
  fi

  if [[ -d "/home/linuxbrew/.linuxbrew/bin" ]]; then
    export PATH="/home/linuxbrew/.linuxbrew/bin:$PATH"
    echo "🍺 Added Homebrew path for Linux."
  elif [[ -d "$HOME/.linuxbrew/bin" ]]; then
    export PATH="$HOME/.linuxbrew/bin:$PATH"
    echo "🍺 Added Homebrew path for Linux (user install)."
  fi
else
  echo -e "\n👍 Homebrew 🍺 is already installed. Proceeding... 🚀\n"
fi

# 2. Choose which Brewfiles to run
BREWFILES_DIR="$HOME/.dotfiles/brewfiles"
declare -a FILES

if [[ "$(uname)" == "Linux" ]]; then
  echo "🖥️ Detected Linux — running core formulae only"
  FILES+=( "$BREWFILES_DIR/Brewfile-base" )
else
  echo "🍎 Detected macOS — installation mode: $mode"
  # Always include base formulae, base casks, and base fonts
  FILES+=(
    "$BREWFILES_DIR/Brewfile-base"
    "$BREWFILES_DIR/brewfile-base-cask"
    "$BREWFILES_DIR/brewfiles-base-fonts"
  )

  # Office-only additions
  if [[ "$mode" == "office" || "$mode" == "all" ]]; then
    FILES+=( "$BREWFILES_DIR/brewfiles-office-cask" )
  fi

  # Private-only additions
  if [[ "$mode" == "private" || "$mode" == "all" ]]; then
    FILES+=( "$BREWFILES_DIR/brewfiles-private-cask" )
  fi
fi

# 3. Run brew bundle on each Brewfile
for f in "${FILES[@]}"; do
  if [[ -f "$f" ]]; then
    echo -e "📦 Installing from $f…\n"
    brew bundle --file="$f"
    echo "✅ Finished $f"
  else
    echo "⚠️ Brewfile not found: $f — skipping"
  fi
done

echo "🎉 All requested bundles complete!"