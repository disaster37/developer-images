FROM docker:dind-rootless

RUN touch /etc/subgid /etc/subuid  && \
    chmod g=u /etc/subgid /etc/subuid /etc/passwd  && \
    echo user:1234:65536 > /etc/subuid  && \
    echo user:1234:65536 > /etc/subgid