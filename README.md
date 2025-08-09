# .dotfiles 

Welcome to my personal dotfiles repository! This collection houses all the configuration files, customizations, and themes that I use to tailor my Linux and macOS environments for an optimal experience. 

## Overview ✨

- **Configuration Files 📝:**  
  All my config files for various applications (shell, editor, window manager, etc.) are version-controlled and organized here for easy setup and maintenance.

- **Customizations ⚙️:**  
  From aliases and environment variables to plugin settings and system tweaks, you'll find everything I use to streamline my workflow.

- **Themes and Aesthetics 🎨:**  
  I include various themes and visual customizations to create a consistent and visually appealing environment across all my systems.

- **Automation and Scripts ⚡:**  
  Custom scripts and bootstrap tools automate the setup process, making it simple to deploy my personalized environment on any new machine.

## Prerequisites 🍺

### 1. **(macOS only) Install Apple's Command Line Tools:**  
If you're on macOS, install these prerequisites first (needed for Git and Homebrew):
```bash
xcode-select --install
``` 

### 2. **Install Homebrew:**
Install the package manager (works on macOS and Linux):
```bash
# Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

After installation, restart your terminal or run `source ~/.zshrc` to ensure `brew` is available.

## Quick Start 🚀

1. **Clone the Repository:**
   ```bash
   # Use HTTPS (recommended for initial setup)...
   git clone https://github.com/UBONGFX/.dotfiles.git ~/.dotfiles

   # ...or use SSH (if you have SSH keys set up)
   git clone git@github.com:UBONGFX/.dotfiles.git ~/.dotfiles
   ```

2. **Install Homebrew Packages & Apps:**
   Install your formulae, casks, and fonts using the package manager:  
   - **Default (no flag):** installs **base**
   - **`--base`:** only core formulae + base casks + fonts  
   - **`--office`:** base + office casks  
   - **`--private`:** base + private casks
   - **Note (Linux):** on Linux the script always runs in default mode but installs only core formulae (casks and fonts are not supported) 
   ```bash
   cd ~/.dotfiles

   # Default (all, macOS only):
   source ./scripts/brew-bootstrap.sh

   # Or limit to base only (also the only mode on Linux):
   source ./scripts/brew-bootstrap.sh --base

   # Or include office GUI apps only:
   source ./scripts/brew-bootstrap.sh --office

   # Or install private casks only:
   source ./scripts/brew-bootstrap.sh --private
   ```

3. **Run the Dotfiles Bootstrap Script:**
   Back up any existing dotfiles and create symlinks to your repo.  
   - **Normal mode** (default): moves old files to a backup folder and replaces them with symlinks.  
   - **Soft mode** (`--soft`): preserves any existing files in place (no backup or linking).  
   ```bash
   # Use this to force changes...
   ./scripts/bootstrap.sh

   # ..or use it with the soft flag
   ./scripts/bootstrap.sh --soft
   ```

4. **Set Your Login Shell to Homebrew Zsh:**
   Ensure you're running the Homebrew‑installed Zsh as your default login shell:  
   - 	Registers the brew‑installed Zsh in /etc/shells if needed.
	-	Runs chsh to update your login shell.
	-	Enter your password when prompted to authorize the change.
   ```bash
   sudo ./scripts/set_shell.sh
   ```

5. **Reload or Restart Your Shell:**
   For all changes to take effect, either open a new terminal window or reload your current session with:
   ```bash
   source ~/.zshrc
   ```

6. **Set Up SSH Keys (Recommended):**
   Create a complete SSH environment with directory, config, and keys:
   ```bash
   ./scripts/ssh-setup.sh
   ```
   
   The script will:
   - Create ~/.ssh directory with proper permissions (700)
   - Copy SSH config from your dotfiles 
   - Generate ed25519 SSH keys if they don't exist
   - Add keys to SSH agent (macOS)
   - Display your public key to add to GitHub

7. **Verify Git Configuration (Optional):**
   Run a health check on your Git setup:
   ```bash
   ./scripts/git-doctor.sh
   ```
   
   This will validate:
   - Git installation and version
   - User configuration (name/email)
   - Global gitignore setup
   - SSH key configuration
   - GitHub connectivity
   - Useful Git aliases

## 🔄 Switching to SSH Remote (Optional)

If you cloned using HTTPS but want to switch to SSH for easier authentication (no password prompts), you can change the remote URL:

1. **First, make sure you have SSH keys set up with GitHub:**
   - Follow [GitHub's SSH key setup guide](https://docs.github.com/en/authentication/connecting-to-github-with-ssh) if you haven't already.

2. **Change the remote URL to SSH:**
   ```bash
   cd ~/.dotfiles
   git remote set-url origin git@github.com:UBONGFX/.dotfiles.git
   ```

3. **Verify the change:**
   ```bash
   git remote -v
   ```

## 🧪 Running Tests

I use [Bats Core](https://github.com/bats-core/bats-core) to validate the scripts. You can install it via Homebrew.

**Run the tests**  
From the repo root, execute:  
```bash
bats --tap tests/ 
```

## 🐳 DevContainer Recommended
 
If you plan to **work on the scripts** or **run the tests locally**, I strongly recommend using the included DevContainer.  
It gives you a clean, isolated environment that matches CI.

1. Install VS Code's **Remote – Containers** extension.  
2. Reopen this folder in a container when prompted.  
