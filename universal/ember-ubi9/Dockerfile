# syntax=docker/dockerfile:1.3-labs

FROM quay.io/webcenter/developer-image:golang-ubi9-latest

#labels for container catalog
LABEL summary="Logstash developer image"
LABEL description="Image to develop with logstash"
LABEL io.k8s.display-name="Logstash"

USER 0
ENV HOME=/home/tooling


## Nodejs
RUN <<EOF
    set -e
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
    \. "$HOME/.nvm/nvm.sh"
    nvm install 24
    npm install -g ember-cli
EOF

USER 10001
ENV HOME=/home/user
