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


# NodeJS
ENV NVM_DIR="/home/user/.nvm"
ENV NODEJS_VERSION=16.14.0
ENV NODEJS_12_VERSION=12.22.10
ENV NODEJS_14_VERSION=14.19.0
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
RUN source /home/user/.bashrc && nvm install v${NODEJS_VERSION} && nvm install v${NODEJS_14_VERSION} && nvm install v${NODEJS_12_VERSION} && nvm alias default v$NODEJS_VERSION && nvm use v$NODEJS_VERSION && npm install --global yarn@v1.22.17
ENV PATH=$NVM_DIR/versions/node/v$NODEJS_VERSION/bin:$PATH
ENV NODEJS_HOME_12=$NVM_DIR/versions/node/v$NODEJS_12_VERSION
ENV NODEJS_HOME_14=$NVM_DIR/versions/node/v$NODEJS_14_VERSION
ENV NODEJS_HOME_16=$NVM_DIR/versions/node/v$NODEJS_VERSION

USER 0

# Required packages for AWT
RUN dnf install -y libXext libXrender libXtst libXi

# Go
ENV GOPATH /go
ENV PATH $GOPATH/bin:$PATH
ENV GOCACHE /.cache
ENV GOROOT /usr/local/go

RUN <<EOF
set -euf -o pipefail
GO_VERSION=1.19.4
mkdir /go /.cache /usr/local/go
chmod -R 777 /.cache /usr/local/go
curl -o- -L https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz | tar xz -C /go --strip-components=1

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
cd /usr/local/go && wget -O- -nv https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s v1.46.2
EOF

# Python
RUN dnf -y module enable python39:3.9 && \
    dnf -y update && \
    dnf -y install python39 python39-devel python39-setuptools python39-pip nss_wrapper && \
    dnf -y clean all --enablerepo='*'

RUN cd /usr/bin \
    && if [ ! -L python ]; then ln -s python3.9 python; fi \
    && if [ ! -L pydoc ]; then ln -s pydoc3.9 pydoc; fi \
    && if [ ! -L python-config ]; then ln -s python3.9-config python-config; fi \
    && if [ ! -L pip ]; then ln -s pip-3.9 pip; fi

RUN pip install pylint yq



# Cloud

# oc
ENV OC_VERSION=4.6
RUN curl -L https://mirror.openshift.com/pub/openshift-v4/clients/oc/${OC_VERSION}/linux/oc.tar.gz | tar -C /usr/local/bin -xz \
    && chmod +x /usr/local/bin/oc

## podman buildah skopeo
RUN dnf -y module enable container-tools:rhel8 && \ 
    dnf -y update && \
    dnf -y reinstall shadow-utils && \
    dnf -y install podman buildah skopeo fuse-overlayfs && \
    dnf -y clean all --enablerepo='*'

# Set up environment variables to note that this is
# not starting with usernamespace and default to
# isolate the filesystem with chroot.
ENV _BUILDAH_STARTED_IN_USERNS="" BUILDAH_ISOLATION=chroot

# Tweaks to make rootless buildah work
RUN touch /etc/subgid /etc/subuid  && \
    chmod g=u /etc/subgid /etc/subuid /etc/passwd  && \
    echo user:1234:65536 > /etc/subuid  && \
    echo user:1234:65536 > /etc/subgid

# Adjust storage.conf to enable Fuse storage.
RUN sed -i -e 's|^#mount_program|mount_program|g' -e '/additionalimage.*/a "/var/lib/shared",' /etc/containers/storage.conf
RUN mkdir -p /var/lib/shared/overlay-images /var/lib/shared/overlay-layers; \
    touch /var/lib/shared/overlay-images/images.lock; \
    touch /var/lib/shared/overlay-layers/layers.lock

# But use VFS since we were not able to make Fuse work yet...
RUN mkdir -p "${HOME}"/.config/containers && \
   (echo '[storage]';echo 'driver = "vfs"') > "${HOME}"/.config/containers/storage.conf

## kubectl
RUN <<EOF
set -euf -o pipefail

cat <<EOF2 > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF2

dnf install -y kubectl
curl -sSL -o ~/.kubectl_aliases https://raw.githubusercontent.com/ahmetb/kubectl-alias/master/.kubectl_aliases
echo '[ -f ~/.kubectl_aliases ] && source ~/.kubectl_aliases' >> /home/user/.bashrc
EOF

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

## helm
RUN <<EOF
set -euf -o pipefail
TEMP_DIR="$(mktemp -d)"
cd "${TEMP_DIR}"
HELM_VERSION="3.7.2"
HELM_ARCH="linux-amd64"
HELM_TGZ="helm-v${HELM_VERSION}-${HELM_ARCH}.tar.gz"
HELM_TGZ_URL="https://get.helm.sh/${HELM_TGZ}"
curl -sSLO "${HELM_TGZ_URL}"
curl -sSLO "${HELM_TGZ_URL}.sha256sum"
sha256sum -c "${HELM_TGZ}.sha256sum" 2>&1 | grep OK
tar -zxvf "${HELM_TGZ}"
mv "${HELM_ARCH}"/helm /usr/local/bin/helm
cd -
rm -rf "${TEMP_DIR}"
EOF

## kustomize
RUN <<EOF
set -euf -o pipefail
TEMP_DIR="$(mktemp -d)"
cd "${TEMP_DIR}"
KUSTOMIZE_VERSION="4.3.0"
KUSTOMIZE_ARCH="linux_amd64"
KUSTOMIZE_TGZ="kustomize_v${KUSTOMIZE_VERSION}_${KUSTOMIZE_ARCH}.tar.gz"
KUSTOMIZE_TGZ_URL="https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2Fv${KUSTOMIZE_VERSION}/${KUSTOMIZE_TGZ}"
KUSTOMIZE_CHEKSUMS_URL="https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2Fv${KUSTOMIZE_VERSION}/checksums.txt"
curl -sSLO "${KUSTOMIZE_TGZ_URL}"
curl -sSLO "${KUSTOMIZE_CHEKSUMS_URL}"
sha256sum --ignore-missing -c "checksums.txt" 2>&1 | grep OK
tar -zxvf "${KUSTOMIZE_TGZ}"
mv kustomize /usr/local/bin/
cd -
rm -rf "${TEMP_DIR}"
EOF

## tektoncd-cli
RUN <<EOF
set -euf -o pipefail
TEMP_DIR="$(mktemp -d)"
cd "${TEMP_DIR}"
TKN_VERSION="0.20.0"
TKN_ARCH="Linux_x86_64"
TKN_TGZ="tkn_${TKN_VERSION}_${TKN_ARCH}.tar.gz"
TKN_TGZ_URL="https://github.com/tektoncd/cli/releases/download/v${TKN_VERSION}/${TKN_TGZ}"
TKN_CHEKSUMS_URL="https://github.com/tektoncd/cli/releases/download/v${TKN_VERSION}/checksums.txt"
curl -sSLO "${TKN_TGZ_URL}"
curl -sSLO "${TKN_CHEKSUMS_URL}"
sha256sum --ignore-missing -c "checksums.txt" 2>&1 | grep OK
tar -zxvf "${TKN_TGZ}"
mv tkn /usr/local/bin/
cd -
rm -rf "${TEMP_DIR}"
EOF

## knative-cli
RUN <<EOF
set -euf -o pipefail
TEMP_DIR="$(mktemp -d)"
cd "${TEMP_DIR}"
KN_VERSION="0.26.0"
KN_ARCH="linux-amd64"
KN_BIN="kn-${KN_ARCH}"
KN_BIN_URL="https://github.com/knative/client/releases/download/v${KN_VERSION}/${KN_BIN}"
KN_CHEKSUMS_URL="https://github.com/knative/client/releases/download/v${KN_VERSION}/checksums.txt"
curl -sSLO "${KN_BIN_URL}"
curl -sSLO "${KN_CHEKSUMS_URL}"
sha256sum --ignore-missing -c "checksums.txt" 2>&1 | grep OK
mv "${KN_BIN}" kn 
chmod +x kn 
mv kn /usr/local/bin
cd -
rm -rf "${TEMP_DIR}"
EOF

## terraform-cli
RUN <<EOF
set -euf -o pipefail
TEMP_DIR="$(mktemp -d)"
cd "${TEMP_DIR}"
TF_VERSION="1.1.2"
TF_ARCH="linux_amd64"
TF_ZIP="terraform_${TF_VERSION}_${TF_ARCH}.zip"
TF_ZIP_URL="https://releases.hashicorp.com/terraform/${TF_VERSION}/${TF_ZIP}"
TF_CHEKSUMS_URL="https://releases.hashicorp.com/terraform/${TF_VERSION}/terraform_${TF_VERSION}_SHA256SUMS"
curl -sSLO "${TF_ZIP_URL}"
curl -sSLO "${TF_CHEKSUMS_URL}"
sha256sum --ignore-missing -c "terraform_${TF_VERSION}_SHA256SUMS" 2>&1 | grep OK
unzip ${TF_ZIP}
chmod +x terraform 
mv terraform /usr/local/bin
cd -
rm -rf "${TEMP_DIR}"
EOF

## terragrunt-cli
RUN <<EOF
set -euf -o pipefail
TERRAGRUNT_VERSION="v0.35.16"
curl -L https://github.com/gruntwork-io/terragrunt/releases/download/${TERRAGRUNT_VERSION}/terragrunt_linux_amd64 -o /usr/bin/terragrunt
chmod +x /usr/bin/terragrunt
EOF

## dagger
RUN <<EOF
set -euf -o pipefail
DAGGER_VERSION="v0.2.8"
curl -o- -L https://github.com/dagger/dagger/releases/download/${DAGGER_VERSION}/dagger_${DAGGER_VERSION}_linux_amd64.tar.gz | tar xvz -C /usr/local/bin --strip-components=0
chmod +x /usr/local/bin/dagger
EOF

## buildkit
RUN <<EOF
set -euf -o pipefail
BUILDKIT_VERSION="0.1.5"
curl -L  https://github.com/vmware-tanzu/buildkit-cli-for-kubectl/releases/download/v${BUILDKIT_VERSION}/kubectl-buildkit-${BUILDKIT_VERSION}-1.el7.x86_64.rpm -o /tmp/kubectl-buildkit.rpm
rpm -i /tmp/kubectl-buildkit.rpm &&\
EOF

## pluto
RUN <<EOF
set -euf -o pipefail
PLUTO_VERSION="5.7.0"
curl -o- -L https://github.com/FairwindsOps/pluto/releases/download/v${PLUTO_VERSION}/pluto_${PLUTO_VERSION}_linux_amd64.tar.gz | tar xvz -C /usr/local/bin --strip-components=0
chmod +x /usr/local/bin/pluto
EOF

## rancher
RUN <<EOF
set -euf -o pipefail
RANCHER_VERSION="v2.4.6"
curl -o- -L https://github.com/rancher/cli/releases/download/${RANCHER_VERSION}/rancher-linux-amd64-${RANCHER_VERSION}.tar.gz | tar xvz -C /usr/local/bin --strip-components=2
chmod +x /usr/local/bin/rancher
EOF

## vault
RUN <<EOF
set -euf -o pipefail
VAULT_VERSION="1.9.2"
TEMP_DIR="$(mktemp -d)"
curl -L https://releases.hashicorp.com/vault/${VAULT_VERSION}/vault_${VAULT_VERSION}_linux_amd64.zip -o ${TEMP_DIR}/vault.zip
cd ${TEMP_DIR}
unzip vault.zip &&\
mv vault /usr/bin/vault &&\
chmod +x /usr/bin/vault &&
EOF

## docker
RUN <<EOF
set -euf -o pipefail
TEMP_DIR="$(mktemp -d)"
cd "${TEMP_DIR}"
DOCKER_VERSION="20.10.8"
DOCKER_ARCH="x86_64"
DOCKER_TGZ="docker-${DOCKER_VERSION}.tgz"
DOCKER_TGZ_URL="https://download.docker.com/linux/static/stable/${DOCKER_ARCH}/${DOCKER_TGZ}"
curl -sSLO "${DOCKER_TGZ_URL}"
tar -zxvf "${DOCKER_TGZ}"
mv docker/docker-proxy \
    docker/containerd \
    docker/dockerd \
    docker/docker \
    docker/containerd-shim-runc-v2 \
    docker/ctr \
    docker/docker-init \
    docker/runc \
    docker/containerd-shim \
    /usr/local/bin/
cd -
rm -rf "${TEMP_DIR}"
EOF

## compose
RUN <<EOF
set -euf -o pipefail
TEMP_DIR="$(mktemp -d)"
cd "${TEMP_DIR}"
COMPOSE_VERSION="1.29.2"
COMPOSE_ARCH="Linux-x86_64"
COMPOSE_BIN="docker-compose-${COMPOSE_ARCH}"
COMPOSE_BIN_URL="https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/${COMPOSE_BIN}"
curl -sSLO "${COMPOSE_BIN_URL}"
curl -sSLO "${COMPOSE_BIN_URL}.sha256"
sha256sum -c "${COMPOSE_BIN}.sha256" 2>&1 | grep OK
chmod +x "${COMPOSE_BIN}"
mv "${COMPOSE_BIN}" /usr/local/bin/docker-compose
cd -
rm -rf "${TEMP_DIR}"
EOF

# e2fsprogs setup
# Since e2fsprogs-static package has removed RHEL 8 distribution, it is not possible to install from the repository
# https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/8/html-single/considerations_in_adopting_rhel_8/index#removed-packages_changes-to-packages
RUN <<EOF
set -euf -o pipefail
TEMP_DIR="$(mktemp -d)"
cd "${TEMP_DIR}"
E2FSPROGS_VERSION="1.46.5"
E2FSPROGS_TGZ="e2fsprogs-${E2FSPROGS_VERSION}.tar.gz"
E2FSPROGS_TGZ_URL="https://mirrors.edge.kernel.org/pub/linux/kernel/people/tytso/e2fsprogs/v${E2FSPROGS_VERSION}/${E2FSPROGS_TGZ}"
E2FSPROGS_CHEKSUMS_URL="https://mirrors.edge.kernel.org/pub/linux/kernel/people/tytso/e2fsprogs/v${E2FSPROGS_VERSION}/sha256sums.asc"
curl -sSLO "${E2FSPROGS_TGZ_URL}"
curl -sSLO "${E2FSPROGS_CHEKSUMS_URL}"
sha256sum --ignore-missing -c "sha256sums.asc" 2>&1 | grep OK
tar -zxvf "${E2FSPROGS_TGZ}"
cd "e2fsprogs-${E2FSPROGS_VERSION}"
mkdir build
cd build
../configure --prefix=/usr --with-root-prefix="" --enable-elf-shlibs --disable-evms
make
make install
make install-libs
cd -
rm -rf "${TEMP_DIR}"
EOF

# Set permissions on /etc/passwd and /home to allow arbitrary users to write
RUN mkdir -p /home/user && chgrp -R 0 /home && chmod -R g=u /etc/passwd /etc/group /home

USER 1234