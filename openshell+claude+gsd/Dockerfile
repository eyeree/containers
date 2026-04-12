FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

# System dependencies (includes iproute2 required by OpenShell)
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    git \
    build-essential \
    python3 \
    python3-venv \
    unzip \
    ca-certificates \
    gnupg \
    sudo \
    jq \
    tmux \
    zsh \
    fzf \
    openssh-client \
    openssh-sftp-server \
    iproute2 \
    nano \
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

# Create supervisor user (used by OpenShell for internal operations)
RUN groupadd -r supervisor && useradd -r -g supervisor -s /usr/sbin/nologin supervisor

# Create sandbox user (required by OpenShell, uid/gid 1000)
RUN userdel -r ubuntu 2>/dev/null || true \
    && groupadd -g 1000 sandbox \
    && useradd -d /sandbox -s /bin/zsh -u 1000 -g sandbox sandbox \
    && mkdir -p /sandbox \
    && chown sandbox:sandbox /sandbox \
    && echo "sandbox ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

USER sandbox
WORKDIR /sandbox
ENV SHELL=/bin/zsh

# Install claude code
COPY --chown=sandbox:sandbox default.claude /sandbox/.claude
ENV CLAUDE_CONFIG_DIR=/sandbox/.claude
RUN curl -fsSL https://claude.ai/install.sh | bash

# Install NVM
ENV NVM_DIR=/sandbox/.nvm
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash

# Install Node 24 via NVM
RUN bash -c '. "$NVM_DIR/nvm.sh" && nvm install 24 && nvm alias default 24'

# Install uv
RUN curl -LsSf https://astral.sh/uv/install.sh | sh

# Install get-shit-done for Claude Code globally
RUN bash -c '. "$NVM_DIR/nvm.sh" && npx get-shit-done-cc@latest --claude --global'

# Copy shell configs to a location outside the home volume
COPY --chown=sandbox:sandbox .zshrc /opt/claude-gsd/.zshrc
COPY --chown=sandbox:sandbox .bashrc /opt/claude-gsd/.bashrc

# Copy entrypoint to a location outside the home volume
COPY --chown=sandbox:sandbox entrypoint.sh /opt/claude-gsd/entrypoint.sh
RUN chmod +x /opt/claude-gsd/entrypoint.sh

ENTRYPOINT ["/opt/claude-gsd/entrypoint.sh"]
