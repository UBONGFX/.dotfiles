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

## Quick Start 🚀

1. **Clone the Repository:**
   ```bash
   git clone https://github.com/username/dotfiles.git ~/.dotfiles
   ```

2. **Run the Bootstrap Script:**
This script will create symlinks to your home directory and set up everything.
   ```bash
   cd ~/.dotfiles && ./bootstrap.sh
   ```

4. **Reload or Restart Your Shell:**  
   For all changes to take effect, either open a new terminal window or reload your current session with:
   ```bash
   source ~/.zshrc
   ```