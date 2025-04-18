#!/bin/bash
# 1. Checks if Homebrew is installed; if not, installs it.
# 2. Uses `brew bundle` with the Brewfile in ~/.dotfiles.

set -euo pipefail

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
  FILES+=( "$BREWFILES_DIR/brewfile" )
else
  echo "🍎 Detected macOS — running formulae, casks, and fonts"
  FILES+=( 
    "$BREWFILES_DIR/brewfile" 
    "$BREWFILES_DIR/brewfile-cask" 
    "$BREWFILES_DIR/brewfiles-fonts"
  )
fi

# 3. Run brew bundle on each Brewfile
for f in "${FILES[@]}"; do
  if [[ -f "$f" ]]; then
    echo "📦 Installing from $f…"
    brew bundle --file="$f"
    echo "✅ Finished $f"
  else
    echo "⚠️ Brewfile not found: $f — skipping"
  fi
done

echo "🎉 All requested bundles complete!"