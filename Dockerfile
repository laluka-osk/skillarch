FROM cachyos/cachyos:latest

# Create hacker user and group, set password and configure sudo
RUN groupadd hacker && \
    useradd -m -g hacker -s /bin/bash hacker && \
    echo "hacker:offenskill" | chpasswd && \
    echo "hacker ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/hacker

# Add skillarch
COPY . /opt/skillarch
RUN chown -R hacker:hacker /opt/skillarch
USER hacker
ENV USER=hacker
ENV TZ=UTC
WORKDIR /opt/skillarch

# Install skillarch
RUN make install-base LITE=1
RUN make install-cli-tools LITE=1
RUN make install-shell LITE=1
RUN make install-docker LITE=1
RUN make install-gui LITE=1
RUN make install-gui-tools LITE=1
RUN make install-offensive LITE=1
RUN make install-wordlists LITE=1
RUN make install-hardening LITE=1
RUN make install-tweaks LITE=1

# Remove NOPASSWD capability after installation
USER root
RUN echo "hacker ALL=(ALL) ALL" > /etc/sudoers.d/hacker

# Final setup
USER hacker
WORKDIR /home/hacker
ENTRYPOINT ["/bin/zsh", "-il"]
