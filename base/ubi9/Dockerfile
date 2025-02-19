# syntax=docker/dockerfile:1.3-labs

FROM quay.io/devfile/base-developer-image:ubi9-latest
LABEL maintainer="disaster37"

ENV HOME=/home/tooling
USER 0

# brotli, compat-openssl11 are required to run che-code
RUN dnf update -y && \
    dnf install -y bash bash-completion iputils sshpass \
                   brotli compat-openssl11 && \
    dnf clean all

# Python
RUN dnf -y install python3 python3-devel python3-setuptools python3-pip nss_wrapper && \
    dnf -y clean all --enablerepo='*'
RUN cd /usr/bin \
    && if [ ! -L python ]; then ln -s python3 python; fi \
    && if [ ! -L pydoc ]; then ln -s pydoc3 pydoc; fi \
    && if [ ! -L python-config ]; then ln -s python3-config python-config; fi
RUN pip install pylint yq

## direnv
RUN <<EOF
DIRENV_VERSION=2.32.2
curl -L https://github.com/direnv/direnv/releases/download/v${DIRENV_VERSION}/direnv.linux-amd64 -o /usr/bin/direnv
chmod +x /usr/bin/direnv
EOF

## Jfrog cli
RUN <<EOF
set -euf -o pipefail

cd /usr/local/bin
curl -fL https://getcli.jfrog.io | sh
chmod +x jfrog
EOF

## dagger.io
RUN <<EOF
set -euf -o pipefail
DAGGER_VERSION="v0.14.0"
curl -o- -L https://github.com/dagger/dagger/releases/download/${DAGGER_VERSION}/dagger_${DAGGER_VERSION}_linux_amd64.tar.gz | tar xvz -C /usr/local/bin --strip-components=0
chmod +x /usr/local/bin/dagger
EOF

## docker
RUN <<EOF
set -euf -o pipefail

dnf install -y yum-utils
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
dnf install -y docker-ce docker-ce-cli containerd.io
EOF

## docker compose
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

## kubectl
RUN <<EOF
set -euf -o pipefail
KUBECTL_VERSION="v1.25.5"

curl -L https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl -o /usr/bin/kubectl
chmod +x /usr/bin/kubectl
EOF

## oc
ENV OC_VERSION=4.17
RUN curl -L https://mirror.openshift.com/pub/openshift-v4/clients/ocp/latest/openshift-client-linux.tar.gz | tar -C /usr/local/bin -xz \
    && chmod +x /usr/local/bin/oc

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

## helm
RUN <<EOF
set -euf -o pipefail
TEMP_DIR="$(mktemp -d)"
cd "${TEMP_DIR}"
HELM_VERSION="3.14.3"
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

## Ansible
RUN <<EOF
set -euf -o pipefail
pip install ansible ansible-core ansible-compat molecule molecule-plugins[docker] docker ansible-lint
pip install boto3
pip install pywinrm
pip install pytest-testinfra
pip install flake8
EOF

## krew
RUN <<EOF
set -euf -o pipefail
TEMP_DIR="$(mktemp -d)"
cd "${TEMP_DIR}"
KREW_VERSION="0.4.4"
KREW_ARCH="linux_amd64"
KREW_TGZ="krew-${KREW_ARCH}.tar.gz"
KREW_TGZ_URL="https://github.com/kubernetes-sigs/krew/releases/download/v${KREW_VERSION}/${KREW_TGZ}"
curl -sSLO "${KREW_TGZ_URL}"
curl -sSLO "${KREW_TGZ_URL}.sha256"

# File ${KREW_TGZ_URL}.sha256 has invalid format to be checked with sha256sum.
# It needs to create a valid one.
echo "$(cat ${KREW_TGZ}.sha256)  ${KREW_TGZ}" > "${KREW_TGZ}.sha256"

sha256sum -c "${KREW_TGZ}.sha256" 2>&1 | grep OK

tar -zxv --no-same-owner -f "${KREW_TGZ}"
./"krew-${KREW_ARCH}" install krew
echo 'export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"' >> ${PROFILE_EXT}
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"
# kubens and kubectx
kubectl krew install ns
kubectl krew install ctx
cd -
rm -rf "${TEMP_DIR}"
EOF
ENV PATH="/home/tooling/.krew/bin:$PATH"

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
RANCHER_VERSION="v2.7.0"
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
unzip vault.zip
mv vault /usr/bin/vault
chmod +x /usr/bin/vault
EOF

# Configure container engine
COPY --chown=0:0 containers.conf /etc/containers/containers.conf

# Configure auto completion
RUN <<EOF
oc completion bash > /usr/share/bash-completion/completions/oc
kubectl completion bash > /usr/share/bash-completion/completions/kubectl
EOF



RUN \
    # Configure sudo
    echo "user ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/user &&\

    # Configure divenv
    echo 'eval "$(direnv hook bash)"' >> /home/tooling/.bashrc &&\

USER 10001

ENV HOME=/home/user
