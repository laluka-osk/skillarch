FROM cachyos/cachyos:latest

# Create hacker user and group, set password and configure sudo
RUN groupadd hacker && \
    useradd -m -g hacker -s /bin/bash hacker && \
    echo "hacker:offenskill" | chpasswd && \
    echo "hacker ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/hacker

USER hacker
WORKDIR /home/hacker

# TODO git clone instead
COPY . skillarch
# RUN git clone https://github.com/laluka/skillarch && \

ENV USER=hacker
RUN sudo mv skillarch /opt/skillarch && \
    cd /opt/skillarch && \
    make install LITE=1

# Remove NOPASSWD capability after installation
USER root
RUN echo "hacker ALL=(ALL) ALL" > /etc/sudoers.d/hacker

USER hacker
# ENTRYPOINT ["/bin/bash", "-il"]
ENTRYPOINT ["/bin/zsh", "-il"]
