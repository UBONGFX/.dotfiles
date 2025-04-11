# Initialize the Zsh completion system
autoload -Uz compinit && compinit
autoload -U +X bashcompinit && bashcompinit

# Helm completion (if installed)
if command -v helm >/dev/null 2>&1; then
  source <(helm completion zsh)
fi

# Kubectl (Kubernetes) completion (if installed)
if command -v kubectl >/dev/null 2>&1; then
  source <(kubectl completion zsh)
fi

# Terraform completion (if installed)
if command -v terraform >/dev/null 2>&1; then
  complete -o nospace -C /opt/homebrew/bin/terraform terraform
fi