FROM cachyos/cachyos:latest

RUN git clone https://github.com/laluka/skillarch && \
    mv skillarch /opt/skillarch && \
    cd /opt/skillarch && \
    make install

ENTRYPOINT ["/bin/zsh", "-il"]