export PATH="/usr/local/bin:$PATH"

export PATH="/opt/homebrew/anaconda3/bin:$PATH"
export PATH="/opt/homebrew/opt/openjdk@17/bin:$PATH"

# Add Flutter to PATH if it exists
if [[ -d "$HOME/Software/flutter/bin" ]]; then
    export PATH="$PATH:$HOME/Software/flutter/bin"
fi

export PATH="$PATH:$HOME/go/bin"

export MANPAGER="sh -c 'col -bx | bat -l man -p'"
export HOMEBREW_CASK_OPTS="--no-quarantine"
