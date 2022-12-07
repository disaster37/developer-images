FROM docker:dind-rootless

USER root

RUN touch /etc/subgid /etc/subuid  && \
    chmod g=u /etc/subgid /etc/subuid /etc/passwd  && \
    echo user:1234:65536 > /etc/subuid  && \
    echo user:1234:65536 > /etc/subgid

USER 1000