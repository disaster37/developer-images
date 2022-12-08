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

LOGSTASH_VERSION="1:7.17.5-1"
FILEBEAT_VERSION="7.16.2-1"
update-crypto-policies --set LEGACY
rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch
dnf install -y java-11-openjdk-headless logstash-${LOGSTASH_VERSION} filebeat-${FILEBEAT_VERSION} diffutils findutils
pip3 install black yamllint yamlfmt
EOF



# Cloud

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
BUILDKIT_VERSION="0.1.6"
curl -L  https://github.com/vmware-tanzu/buildkit-cli-for-kubectl/releases/download/v${BUILDKIT_VERSION}/kubectl-buildkit-${BUILDKIT_VERSION}-1.el7.x86_64.rpm -o /tmp/kubectl-buildkit.rpm
rpm -i /tmp/kubectl-buildkit.rpm
EOF

# Set permissions on /etc/passwd and /home to allow arbitrary users to write
RUN mkdir -p /home/user && chgrp -R 0 /home && chmod -R g=u /etc/passwd /etc/group /home

USER 1234
