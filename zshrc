[[ -f ~/.zsh/completions.zsh ]] && source ~/.zsh/completions.zsh
[[ -f ~/.zsh/aliases.zsh ]] && source ~/.zsh/aliases.zsh
[[ -f ~/.zsh/plugins.zsh ]] && source ~/.zsh/plugins.zsh
[[ -f ~/.zsh/nvm.zsh ]] && source ~/.zsh/nvm.zsh

# Initialize Starship prompt
eval "$(starship init zsh)"

echo -e "\n💻 Welcome, $(whoami)! \nToday is $(date '+%A, %d %B %Y'). \nOK LETS GO!!! 🚀🔥🤘"
