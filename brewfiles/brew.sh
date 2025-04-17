#!/bin/bash
# 1. Checks if Homebrew is installed; if not, installs it.
# 2. Uses `brew bundle` with the Brewfile in ~/.dotfiles.

# 1. Check if Homebrew is installed
if ! command -v brew &> /dev/null; then
  echo "🚀 Homebrew 🍺 is not installed. Attempting to install... 🔧"

  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  if [ $? -ne 0 ]; then
    echo "❌ Failed to install Homebrew 🍺. Please check your internet connection or retry manually. 🌐"
    exit 1
  else
    echo "✅ Homebrew 🍺 installed successfully! 🎉"
    
    # Add Homebrew to your PATH
    if [ -d "/opt/homebrew/bin" ]; then
      export PATH="/opt/homebrew/bin:$PATH"
      echo "🍺 Added Homebrew path for Apple Silicon."
    fi

    if [ -d "/home/linuxbrew/.linuxbrew/bin" ]; then
      export PATH="/home/linuxbrew/.linuxbrew/bin:$PATH"
      echo "🍺 Added Homebrew path for Linux."
    elif [ -d "$HOME/.linuxbrew/bin" ]; then
      export PATH="$HOME/.linuxbrew/bin:$PATH"
      echo "🍺 Added Homebrew path for Linux (user install)."
    fi
  fi
else
  echo -e "\n👍 Homebrew 🍺 is already installed. Proceeding... 🚀\n"
fi

# 2. Install everything from the Brewfile
BREWFILE_PATH="$HOME/.dotfiles/Brewfile"
if [ -f "$BREWFILE_PATH" ]; then
  echo "Found Brewfile at '$BREWFILE_PATH'. Running 'brew bundle' now..."
  if brew bundle --file "$BREWFILE_PATH"; then
    echo "All packages installed from Brewfile."
  else
    echo "Error occurred while running 'brew bundle'."
    exit 1
  fi
else
  echo "No Brewfile found at '$BREWFILE_PATH'. Please create or move it there and rerun."
  exit 1
fi

echo "Script completed successfully."