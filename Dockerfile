# Base image with core system setup
FROM cachyos/cachyos:latest AS install-base
RUN groupadd hacker && \
    useradd -m -g hacker -s /bin/bash hacker && \
    echo "hacker:offenskill" | chpasswd && \
    echo "hacker ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/hacker

# CLI tools installation
FROM install-base AS install-cli-tools
USER hacker
COPY . /opt/skillarch
WORKDIR /opt/skillarch
RUN make install-cli-tools LITE=1

# Shell customization
FROM install-cli-tools AS install-shell
RUN make install-shell LITE=1

# Docker installation
FROM install-shell AS install-docker
RUN make install-docker LITE=1

# GUI base installation
FROM install-docker AS install-gui
RUN make install-gui LITE=1

# GUI tools installation
FROM install-gui AS install-gui-tools
RUN make install-gui-tools LITE=1

# Offensive tools installation
FROM install-gui-tools AS install-offensive
RUN make install-offensive LITE=1

# Wordlists installation
FROM install-offensive AS install-wordlists
RUN make install-wordlists LITE=1

# System hardening
FROM install-wordlists AS install-hardening
RUN make install-hardening LITE=1

# Final tweaks and cleanup
FROM install-hardening AS install-tweaks

USER root
RUN echo "hacker ALL=(ALL) ALL" > /etc/sudoers.d/hacker

USER hacker
ENV USER=hacker
ENTRYPOINT ["/bin/zsh", "-il"]
