# syntax=docker/dockerfile:1.3-labs

FROM quay.io/webcenter/developer-image:golang-ubi9-latest

#labels for container catalog
LABEL summary="Logstash developer image"
LABEL description="Image to develop with logstash"
LABEL io.k8s.display-name="Logstash"



USER 0
ENV HOME=/home/tooling


## Logstash-filter-verifier

RUN <<EOF
set -euf -o pipefail

LOGSTASH_FILTER_VERIFIER_VERSION="1.6.3"
curl -o- -L https://github.com/magnusbaeck/logstash-filter-verifier/releases/download/${LOGSTASH_FILTER_VERIFIER_VERSION}/logstash-filter-verifier_${LOGSTASH_FILTER_VERIFIER_VERSION}_linux_amd64.tar.gz | tar xvz -C /usr/local/bin --strip-components=1
chmod +x /usr/local/bin/logstash-filter-verifier
EOF

## Logstash / filebeat
COPY root/ /
RUN <<EOF
set -euf -o pipefail

LOGSTASH_VERSION="1:8.7.1-1"
FILEBEAT_VERSION="8.7.1-1"
update-crypto-policies --set LEGACY
rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch
dnf install -y java-11-openjdk-headless logstash-${LOGSTASH_VERSION} filebeat-${FILEBEAT_VERSION} diffutils findutils
pip3 install black yamllint yamlfmt
EOF


USER 10001
ENV HOME=/home/user
