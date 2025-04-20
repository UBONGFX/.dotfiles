#!/bin/bash
# Ensures your login shell is the Homebrew‑installed Zsh:
#   • Detects the real user (handles sudo vs. direct run) 🔍
#   • Determines Homebrew’s installation prefix via `brew --prefix` 🏷️
#   • Registers the brew Zsh in /etc/shells if needed ➕
#   • Changes your login shell to brew Zsh (unless it’s already set) 🔄
#   • Prints a confirmation or skips if already correct ✅

set -euo pipefail

# 1. Detect the actual user
target_user="$(id -un)"

# 2. Ensure brew is available
if ! command -v brew &>/dev/null; then
  echo "❌ Homebrew not found—cannot determine Zsh path."
  exit 1
fi

brew_prefix="$(brew --prefix)"
zsh_path="$brew_prefix/bin/zsh"

if [[ ! -x "$zsh_path" ]]; then
  echo "❌ Brew‐installed Zsh not found at $zsh_path."
  exit 1
fi

echo "🔍 Brew prefix: $brew_prefix"
echo "🔍 Found Zsh at: $zsh_path"

# 2. See what shell we’re currently using
if [[ "$SHELL" == "$zsh_path" ]]; then
  echo -e "\n✅ Already running brew‐installed Zsh ($zsh_path), skipping change."
  exit 0
fi

# 3b. Ensure it’s an allowed login shell
if ! grep -Fxq "$zsh_path" /etc/shells; then
  echo "➕ Adding $zsh_path to /etc/shells"
  echo "$zsh_path" | sudo tee -a /etc/shells >/dev/null
fi

# 4. Change login shell to brew’s Zsh unconditionally
echo -e "\n🔄 Setting login shell for '$target_user' to brew Zsh ($zsh_path)…"
if chsh -s "$zsh_path" "$target_user"; then
  echo -e "✅ Login shell for '$target_user' is now Zsh. Please restart your terminal.\n"
else
  echo -e "❌ Failed to change shell. You can run:\n    chsh -s $zsh_path $target_user\n"
  exit 1
fi
