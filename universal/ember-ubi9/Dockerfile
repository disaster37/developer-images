# syntax=docker/dockerfile:1.3-labs

FROM quay.io/webcenter/developer-image:golang-ubi9-latest

#labels for container catalog
LABEL summary="Logstash developer image"
LABEL description="Image to develop with logstash"
LABEL io.k8s.display-name="Logstash"

USER 0
ENV HOME=/home/tooling


## Nodejs
ENV NVM_DIR="/home/tooling/.nvm"
RUN <<EOF
    set -e
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
    mkdir -p /home/tooling/.nvm/
    echo 'export NVM_DIR="$HOME/.nvm"' >> ${PROFILE_EXT}
    echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' >> ${PROFILE_EXT}
    source /home/user/.bashrc
    nvm install 24
    npm install -g ember-cli@6.5.0
    chgrp -R 0 /home/tooling && chmod -R g=u /home/tooling
EOF

USER 10001
ENV HOME=/home/user
