#!/bin/bash
# Installs packages from your brewfiles:
#   • Requires Homebrew to be pre-installed 🍺
#   • Supports modes: --base, --office, --private (default: all) ⚙️
#   • Runs `brew bundle` on each selected brewfile 📦✅
#   • Cross-platform: adapts to macOS vs Linux 🌍

set -euo pipefail

# Ensure Homebrew is available
if ! command -v brew &>/dev/null; then
  echo "❌ Homebrew not found!"
  echo ""
  echo "🔧 Please install Homebrew first:"
  echo "   /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
  echo ""
  echo "   Then restart your terminal or run: source ~/.zshrc"
  echo "   More info: https://brew.sh"
  exit 1
fi

# Parse mode flag
mode="base"
if [[ "${1:-}" == "--base" ]]; then
  mode="base"
elif [[ "${1:-}" == "--office" ]]; then
  mode="office"
elif [[ "${1:-}" == "--private" ]]; then
  mode="private"
elif [[ "${1:-}" == "--all" ]]; then
  mode="all"
elif [[ "${1:-}" =~ ^-- ]]; then
  echo "❌ Unknown flag: $1"
  echo ""
  echo "Usage: $0 [--base|--office|--private|--all]"
  echo "  --base     Install base formulae only"
  echo "  --office   Install base + office applications"  
  echo "  --private  Install base + private applications"
  echo "  --all      Install everything (default)"
  exit 1
fi

echo -e "\n🍺 Brew Package Installer"
echo "▶ Installation mode: $mode"
echo "▶ Homebrew version: $(brew --version | head -n1)"

# Choose which brewfiles to run
BREWFILES_DIR="$HOME/.dotfiles/brewfiles"
declare -a FILES

if [[ "$(uname)" == "Linux" ]]; then
  echo "� Detected Linux — running core formulae only"
  FILES+=( "$BREWFILES_DIR/Brewfile-base" )
else
  echo "🍎 Detected macOS — installation mode: $mode"
  # Always include base formulae, base casks, and base fonts
  FILES+=(
    "$BREWFILES_DIR/Brewfile-base"
    "$BREWFILES_DIR/Brewfile-base-casks"
    "$BREWFILES_DIR/Brewfile-base-fonts"
  )

  # Office-only additions
  if [[ "$mode" == "office" || "$mode" == "all" ]]; then
    FILES+=( "$BREWFILES_DIR/Brewfile-office-casks" )
  fi

  # Private-only additions
  if [[ "$mode" == "private" || "$mode" == "all" ]]; then
    FILES+=( "$BREWFILES_DIR/Brewfile-private-casks" )
  fi
fi

# Run brew bundle on each brewfile
for f in "${FILES[@]}"; do
  if [[ -f "$f" ]]; then
    echo -e "📦 Installing from $f...\n"
    brew bundle --file="$f"
    echo "✅ Finished $f"
  else
    echo "⚠️ Brewfile not found: $f — skipping"
  fi
done

echo "🎉 All requested bundles complete!"