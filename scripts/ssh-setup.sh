#!/usr/bin/env bash
# SSH Setup Script:
#   • Creates SSH directory with proper permissions 🔐
#   • Copies SSH config from dotfiles 📝
#   • Generates SSH keys if they don't exist 🔑
#   • Adds keys to SSH agent (macOS) 🍎
#   • Tests GitHub connection ✅

set -euo pipefail

# Configuration
SSH_DIR="$HOME/.ssh"
CONFIG_FILE="${SSH_DIR}/config"
KEY_FILE="${SSH_DIR}/id_ed25519"
KEY_TYPE="ed25519"
KEY_COMMENT="${USER}@$(hostname -s)"
DOTFILES_SSH_CONFIG="$HOME/.dotfiles/config/ssh/config"

echo -e "\n🔐 Setting up SSH environment..."

# Check if SSH is already fully configured
if [[ -d "$SSH_DIR" ]] && [[ -f "$CONFIG_FILE" ]] && [[ -f "$KEY_FILE" ]]; then
    echo -e "\n⚠️ SSH is already fully configured!"
    echo "Directory: $SSH_DIR ✓"
    echo "Config: $CONFIG_FILE ✓" 
    echo "Key: $KEY_FILE ✓"
    echo -e "\nPublic key:"
    cat "${KEY_FILE}.pub"
    echo -e "\nTo add this key to GitHub, visit: https://github.com/settings/ssh/new"
    exit 0
fi

# Create SSH directory with proper permissions
if [[ ! -d "$SSH_DIR" ]]; then
    echo -e "\n📁 Creating SSH directory: $SSH_DIR"
    mkdir -p "$SSH_DIR"
    chmod 700 "$SSH_DIR"
    echo "✅ SSH directory created"
else
    echo "✅ SSH directory already exists"
fi

# Setup SSH config file
if [[ ! -f "$CONFIG_FILE" ]]; then
    echo -e "\n📝 Creating SSH config file"
    if [[ -f "$DOTFILES_SSH_CONFIG" ]]; then
        cp "$DOTFILES_SSH_CONFIG" "$CONFIG_FILE"
        chmod 600 "$CONFIG_FILE"
        echo "✅ SSH config copied from dotfiles"
    else
        echo "❌ Error: Dotfiles SSH config not found at $DOTFILES_SSH_CONFIG"
        echo "   Please ensure your dotfiles are properly set up"
        exit 1
    fi
else
    echo "✅ SSH config already exists"
fi

# Generate SSH keys if they don't exist
if [[ ! -f "$KEY_FILE" ]]; then
    echo -e "\n🔑 Generating SSH keys"
    ssh-keygen -t "$KEY_TYPE" -C "$KEY_COMMENT" -f "$KEY_FILE" -N ""
    chmod 600 "$KEY_FILE"
    chmod 644 "${KEY_FILE}.pub"
    echo "✅ SSH keys generated successfully!"
else
    echo "✅ SSH keys already exist"
fi

# Add to SSH agent on macOS
if [[ "$OSTYPE" == "darwin"* ]] && command -v ssh-add >/dev/null; then
    echo -e "\n🍎 Adding key to SSH agent (macOS)"
    ssh-add --apple-use-keychain "$KEY_FILE" 2>/dev/null || ssh-add "$KEY_FILE"
    echo "✅ Key added to SSH agent"
fi

echo -e "\n🎉 SSH setup completed!\n"
echo "📋 Your public key (copy this to GitHub/servers):"
echo -e "$(cat "${KEY_FILE}.pub")\n"
echo "🔗 Next steps:"
echo "1. Copy the public key above"  
echo "2. Add it to GitHub: https://github.com/settings/ssh/new"
echo "3. Test connection: ssh -T git@github.com"
