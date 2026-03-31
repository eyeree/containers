#!/bin/zsh

# Parse arguments: repos before --, command after --
REPOS=()
CMD_ARGS=()
SEEN_DASHDASH=false
while [ $# -gt 0 ]; do
    if $SEEN_DASHDASH; then
        CMD_ARGS+=("$1")
    elif [ "$1" = "--" ]; then
        SEEN_DASHDASH=true
    else
        REPOS+=("$1")
    fi
    shift
done

# Load environment from uploaded env file
if [ -d "$HOME/.tmpenv" ]; then
    mv "$HOME/.tmpenv"/* "$HOME/.env"
    rm -r "$HOME/.tmpenv"
    set -a
    source "$HOME/.env"
    set +a
fi

# Copy build-time config files into the home volume so they stay up to date
cp /opt/claude-gsd/.zshrc "$HOME/.zshrc"
cp /opt/claude-gsd/.bashrc "$HOME/.bashrc"

# Source NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"

# Add uv/local bins to PATH
export PATH="$HOME/.local/bin:$PATH"

# Configure git identity if provided
[ -n "${GIT_USER_NAME:-}" ] && git config --global user.name "$GIT_USER_NAME"
[ -n "${GIT_USER_EMAIL:-}" ] && git config --global user.email "$GIT_USER_EMAIL"

# Authenticate gh if GH_TOKEN is set
if [ -n "${GH_TOKEN:-}" ]; then
    echo "Initializing git auth..."
    echo "$GH_TOKEN" | gh auth login --with-token 2>/dev/null
    gh auth setup-git
fi

# Update claude code marketplace in fresh container
export CLAUDE_CONFIG_DIR=$HOME/.claude
if [ ! -d "$CLAUDE_CONFIG_DIR/plugins/marketplaces/claude-plugins-official" ]; then
    echo "Initializing claude code marketplaces..."
    claude plugin marketplace update 2>/dev/null
fi

# Clone all specified repos
for repo in "${REPOS[@]}"; do
    echo "Cloning $repo..."
    git clone "$repo"
done

# If exactly one repo, start in its directory
if [ ${#REPOS[@]} -eq 1 ]; then
    dir=$(basename "${REPOS[1]}" .git)
    cd "$dir"
fi

# Run command (default: claude inside interactive zsh)
if [ ${#CMD_ARGS[@]} -eq 0 ]; then
    # Start interactive zsh which auto-launches claude via precmd hook.
    # ctrl+z suspends claude to the shell; when claude exits normally, shell exits too.
    export CLAUDE_AUTOSTART=1
    exec zsh -i
else
    exec "${CMD_ARGS[@]}"
fi
