#!/bin/zsh

# Load environment from uploaded .env file (workaround for provider credential injection)
if [ -f "$HOME/.env" ]; then
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

# Parse arguments: repos before --, command after --
REPOS=()
CMD_ARGS=()
SEEN_DASHDASH=false
for arg in "$@"; do
    if [[ "$SEEN_DASHDASH" == "true" ]]; then
        CMD_ARGS+=("$arg")
    elif [[ "$arg" == "--" ]]; then
        SEEN_DASHDASH=true
    else
        REPOS+=("$arg")
    fi
done

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

# Run command (default: claude)
if [ ${#CMD_ARGS[@]} -eq 0 ]; then
    exec claude --dangerously-skip-permissions
else
    exec "${CMD_ARGS[@]}"
fi
