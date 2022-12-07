FROM docker:dind-rootless

USER root

RUN \
    touch /etc/subgid /etc/subuid  && \
    chmod g=u /etc/subgid /etc/subuid /etc/passwd  && \
    echo user:10000:65536 > /etc/subuid  && \
    echo user:10000:65536 > /etc/subgid

RUN \
    addgroup -g 1234 user && \
    adduser -g "user" -D -h /home/user -G user -s /bin/bash -u 1234 user

USER 1234