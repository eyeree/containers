FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

# System dependencies
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    git \
    build-essential \
    python3 \
    unzip \
    ca-certificates \
    gnupg \
    sudo \
    jq \
    tmux \
    zsh \
    fzf \
    openssh-client \
    # Java runtime for Firebase emulators
    default-jdk-headless \
    # Chrome dependencies for agent-browser
    fonts-liberation \
    libasound2t64 \
    libatk-bridge2.0-0t64 \
    libatk1.0-0t64 \
    libatspi2.0-0t64 \
    libcairo2 \
    libcups2t64 \
    libdbus-1-3 \
    libdrm2 \
    libgbm1 \
    libglib2.0-0t64 \
    libnspr4 \
    libnss3 \
    libpango-1.0-0 \
    libx11-6 \
    libxcb1 \
    libxcomposite1 \
    libxdamage1 \
    libxext6 \
    libxfixes3 \
    libxkbcommon0 \
    libxrandr2 \
    libxshmfence1 \
    xdg-utils \
    && rm -rf /var/lib/apt/lists/*

# Install gh CLI
RUN mkdir -p -m 755 /etc/apt/keyrings \
    && out=$(mktemp) \
    && wget -nv -O "$out" https://cli.github.com/packages/githubcli-archive-keyring.gpg \
    && cat "$out" | tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null \
    && chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
       | tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
    && apt-get update \
    && apt-get install -y gh \
    && rm -rf /var/lib/apt/lists/*

# Replace default ubuntu user (UID 1000) with sandbox user to match host UID
RUN userdel -r ubuntu \
    && useradd -m -s /bin/zsh -u 1000 sandbox \
    && echo "sandbox ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

USER sandbox
WORKDIR /home/sandbox

# Install claude-code
RUN curl -fsSL https://claude.ai/install.sh | bash

# Install NVM
ENV NVM_DIR=/home/sandbox/.nvm
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash

# Install Node 24 via NVM
RUN bash -c '. "$NVM_DIR/nvm.sh" && nvm install 24 && nvm alias default 24'

# Install global npm packages
RUN bash -c '. "$NVM_DIR/nvm.sh" && npm install -g pnpm firebase firebase-tools tsx agent-browser'

# Download Chrome for agent-browser (system deps installed above)
RUN bash -c '. "$NVM_DIR/nvm.sh" && agent-browser install'

# Copy default .zshrc to a location outside the home volume
COPY --chown=sandbox:sandbox .zshrc /opt/sandbox/.zshrc

# Copy initial claude code configuration directory
COPY --chown=sandbox:sandbox default.claude /home/sandbox/.claude

# Install uv
RUN curl -LsSf https://astral.sh/uv/install.sh | sh

# Install basic-memory via uv tool
RUN /home/sandbox/.local/bin/uv tool install basic-memory

# Copy entrypoint to a location outside the home volume
COPY --chown=sandbox:sandbox entrypoint.sh /opt/sandbox/entrypoint.sh
RUN chmod +x /opt/sandbox/entrypoint.sh

ENTRYPOINT ["/opt/sandbox/entrypoint.sh"]
CMD ["/bin/zsh"]
