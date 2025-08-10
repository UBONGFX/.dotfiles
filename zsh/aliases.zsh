echo "🚧 Loading aliases"

# Git aliases
alias gs='git status'
alias gc='git commit'
alias gb='git branch'
alias gf='git fetch'
alias gp='git pull'
alias ga='git add'

# ls replacements
alias ll='ls -lah -g --icons --git'
alias la='eza -l -a -g --icons --git'
alias ls='eza --icons --git'

# Infrastructure tools
alias k='kubectl'
alias t='terraform'
alias h='helm'
alias a='ansible'

# Ripgrep aliases for better searching
alias rg='ripgrep'
alias rgf='rg --files-with-matches'
alias rgi='rg --ignore-case'
alias rgw='rg --word-regexp'
alias rgjs='rg --type js'
alias rgpy='rg --type py'
alias rgmd='rg --type md'
