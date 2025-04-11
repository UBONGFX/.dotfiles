[[ -f ~/.zsh/aliases.zsh ]] && source ~/.zsh/aliases.zsh
[[ -f ~/.zsh/nvm.zsh ]] && source ~/.zsh/nvm.zsh

# ~/.zsh/startup.zsh
# Set environment variables
export PATH="/usr/local/bin:$PATH"

export PATH="/opt/homebrew/anaconda3/bin:$PATH"
export PATH="$PATH:/Users/jordiisken/Software/flutter/bin"
export PATH="/opt/homebrew/opt/openjdk@17/bin:$PATH"
export PATH=$PATH:$HOME/go/bin

# Initialize Starship prompt
eval "$(starship init zsh)"

# Any custom startup commands
echo "Welcome, $(whoami)! Today is $(date '+%A, %d %B %Y')"

