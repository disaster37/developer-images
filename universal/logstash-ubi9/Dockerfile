# syntax=docker/dockerfile:1.3-labs

FROM quay.io/webcenter/developer-image:base-ubi9-latest
LABEL maintainer="Red Hat, Inc."

LABEL com.redhat.component="devfile-universal-container"
LABEL name="devfile/universal-developer-image"
LABEL version="ubi9"

#label for EULA
LABEL com.redhat.license_terms="https://www.redhat.com/en/about/red-hat-end-user-license-agreements#UBI"

#labels for container catalog
LABEL summary="devfile universal developer image"
LABEL description="Image with developers tools. Languages SDK and runtimes included."
LABEL io.k8s.display-name="devfile-developer-universal"
LABEL io.openshift.expose-services=""

USER 1234


USER 0


# Python
RUN dnf -y install python3 python3-devel python3-setuptools python3-pip nss_wrapper && \
    dnf -y clean all --enablerepo='*'

RUN cd /usr/bin \
    && if [ ! -L python ]; then ln -s python3 python; fi \
    && if [ ! -L pydoc ]; then ln -s pydoc3 pydoc; fi \
    && if [ ! -L python-config ]; then ln -s python3-config python-config; fi

RUN pip install pylint yq

# Go
RUN dnf install -y gcc
ENV GOROOT /go
ENV GOPATH /go
ENV PATH $GOROOT/bin:$PATH
ENV GOCACHE /.cache

RUN <<EOF
set -euf -o pipefail
GO_VERSION=1.22.5
mkdir -p /go /.cache /projects
curl -o- -L https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz | tar xz -C /go --strip-components=1
chmod -R 777 /.cache /go /projects

go install github.com/acroca/go-symbols@latest &&\
go install github.com/cweill/gotests/gotests@latest &&\
go install github.com/davidrjenni/reftools/cmd/fillstruct@latest &&\
go install github.com/haya14busa/goplay/cmd/goplay@latest &&\
go install github.com/stamblerre/gocode@latest &&\
mv /go/bin/gocode /go/bin/gocode-gomod &&\
go install github.com/mdempsky/gocode@latest &&\
go install github.com/ramya-rao-a/go-outline@latest &&\
go install github.com/rogpeppe/godef@latest &&\
go install github.com/sqs/goreturns@latest &&\
go install github.com/uudashr/gopkgs/v2/cmd/gopkgs@latest &&\
go install github.com/zmb3/gogetdoc@latest &&\
go install honnef.co/go/tools/cmd/staticcheck@latest &&\
go install golang.org/x/tools/cmd/gorename@latest &&\
go install github.com/go-delve/delve/cmd/dlv@latest &&\
go install golang.org/x/tools/gopls@latest &&\
cd /go && wget -O- -nv https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s v1.57.2
EOF
ENV GOPATH /projects
ENV PATH $GOPATH/bin:$PATH



# Applications

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



# Cloud

## shellcheck
RUN <<EOF
dnf install -y xz
set -euf -o pipefail
TEMP_DIR="$(mktemp -d)"
cd "${TEMP_DIR}"
SHELL_CHECK_VERSION="0.8.0"
SHELL_CHECK_ARCH="x86_64"
SHELL_CHECK_TGZ="shellcheck-v${SHELL_CHECK_VERSION}.linux.${SHELL_CHECK_ARCH}.tar.xz"
SHELL_CHECK_TGZ_URL="https://github.com/koalaman/shellcheck/releases/download/v${SHELL_CHECK_VERSION}/${SHELL_CHECK_TGZ}"
curl -sSLO "${SHELL_CHECK_TGZ_URL}"
tar -xvf "${SHELL_CHECK_TGZ}"
mv "${TEMP_DIR}"/shellcheck-v${SHELL_CHECK_VERSION}/shellcheck /bin/shellcheck
cd -
rm -rf "${TEMP_DIR}"
EOF

## krew
RUN <<EOF
set -euf -o pipefail
TEMP_DIR="$(mktemp -d)"
cd "${TEMP_DIR}"
KREW_VERSION="0.4.2"
KREW_ARCH="linux_amd64"
KREW_TGZ="krew-${KREW_ARCH}.tar.gz"
KREW_TGZ_URL="https://github.com/kubernetes-sigs/krew/releases/download/v${KREW_VERSION}/${KREW_TGZ}"
curl -sSLO "${KREW_TGZ_URL}"
curl -sSLO "${KREW_TGZ_URL}.sha256"

# File ${KREW_TGZ_URL}.sha256 has invalid format to be checked with sha256sum.
# It needs to create a valid one.
echo "$(cat ${KREW_TGZ}.sha256)  ${KREW_TGZ}" > "${KREW_TGZ}.sha256"

sha256sum -c "${KREW_TGZ}.sha256" 2>&1 | grep OK

tar -zxvf "${KREW_TGZ}"
./"krew-${KREW_ARCH}" install krew
echo 'export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"' >> /home/user/.bashrc
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"
# kubens and kubectx
kubectl krew install ns
kubectl krew install ctx
cd -
rm -rf "${TEMP_DIR}"
EOF

## buildkit
RUN <<EOF
set -euf -o pipefail
BUILDKIT_VERSION="0.1.6"
curl -L  https://github.com/vmware-tanzu/buildkit-cli-for-kubectl/releases/download/v${BUILDKIT_VERSION}/kubectl-buildkit-${BUILDKIT_VERSION}-1.el7.x86_64.rpm -o /tmp/kubectl-buildkit.rpm
rpm -i /tmp/kubectl-buildkit.rpm
EOF

# Set permissions on /etc/passwd and /home to allow arbitrary users to write
RUN mkdir -p /home/user && chgrp -R 0 /home && chmod -R g=u /etc/passwd /etc/group /home

USER 1234
