#!/bin/zsh

# Copy build-time config files into the home volume so they stay up to date
cp /opt/sandbox/.zshrc "$HOME/.zshrc"

# Source NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"

# Configure git identity if provided
if [ -n "$GIT_USER_NAME" ]; then
    git config --global user.name "$GIT_USER_NAME"
fi
if [ -n "$GIT_USER_EMAIL" ]; then
    git config --global user.email "$GIT_USER_EMAIL"
fi
git config --global core.editor "code --wait"

# Authenticate gh if GH_TOKEN is set
# if [ ! -n "$GH_TOKEN" ]; then 
#     echo "GH_TOKEN not set."
#     exit 1
# fi
# echo "\nInitialing git auth: "
# echo "$GH_TOKEN" | gh auth login --with-token
# gh auth setup-git
# gh auth status

# Update claude code marketplace in fresh container
if [ ! -d "$HOME/.claude/plugins/marketplaces/claude-plugins-official" ]; then
    echo "\nInitializing claude code marketplaces"
    $HOME/.local/bin/claude plugin marketplace update
fi

echo "\n"
claude mcp list

if [ -d "$HOME/workspace" ]; then
    cd "$HOME/workspace"
fi

echo "\n"
git status

exec "$@"
