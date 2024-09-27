# syntax=docker/dockerfile:1.3-labs

FROM registry.access.redhat.com/ubi9/ubi
LABEL maintainer="Red Hat, Inc."

LABEL com.redhat.component="devfile-base-container"
LABEL name="devfile/base-developer-image"
LABEL version="ubi9"

#label for EULA
LABEL com.redhat.license_terms="https://www.redhat.com/en/about/red-hat-end-user-license-agreements#UBI"

#labels for container catalog
LABEL summary="devfile base developer image"
LABEL description="Image with base developers tools. Languages SDK and runtimes excluded."
LABEL io.k8s.display-name="devfile-developer-base"
LABEL io.openshift.expose-services=""

USER 0

ENV HOME=/home/tooling
RUN mkdir -p /home/tooling/

# curl already installed on ubi9
# brotli, compat-openssl11 are required to run che-code
RUN dnf install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm && \
    dnf update -y && \
    dnf install -y https://rpmfind.net/linux/epel/9/Everything/x86_64/Packages/s/stow-2.4.0-1.el9.noarch.rpm &&\
    dnf install -y bash curl diffutils git git-lfs iproute jq less lsof man nano procps p7zip p7zip-plugins bash-completion iputils sshpass \
                   perl-Digest-SHA net-tools openssh-clients rsync socat sudo time vim wget zip stow brotli compat-openssl11 && \
                   dnf clean all

## direnv
RUN <<EOF
DIRENV_VERSION=2.32.2
curl -L https://github.com/direnv/direnv/releases/download/v${DIRENV_VERSION}/direnv.linux-amd64 -o /usr/bin/direnv
chmod +x /usr/bin/direnv
EOF

## gh-cli
RUN \
    TEMP_DIR="$(mktemp -d)"; \
    cd "${TEMP_DIR}"; \
    GH_VERSION="2.0.0"; \
    GH_ARCH="linux_amd64"; \
    GH_TGZ="gh_${GH_VERSION}_${GH_ARCH}.tar.gz"; \
    GH_TGZ_URL="https://github.com/cli/cli/releases/download/v${GH_VERSION}/${GH_TGZ}"; \
    GH_CHEKSUMS_URL="https://github.com/cli/cli/releases/download/v${GH_VERSION}/gh_${GH_VERSION}_checksums.txt"; \
    curl -sSLO "${GH_TGZ_URL}"; \
    curl -sSLO "${GH_CHEKSUMS_URL}"; \
    sha256sum --ignore-missing -c "gh_${GH_VERSION}_checksums.txt" 2>&1 | grep OK; \
    tar -zxvf "${GH_TGZ}"; \
    mv "gh_${GH_VERSION}_${GH_ARCH}"/bin/gh /usr/local/bin/; \
    cd -; \
    rm -rf "${TEMP_DIR}"

## ripgrep
RUN \
    TEMP_DIR="$(mktemp -d)"; \
    cd "${TEMP_DIR}"; \
    RG_VERSION="13.0.0"; \
    RG_ARCH="x86_64-unknown-linux-musl"; \
    RG_TGZ="ripgrep-${RG_VERSION}-${RG_ARCH}.tar.gz"; \
    RG_TGZ_URL="https://github.com/BurntSushi/ripgrep/releases/download/${RG_VERSION}/${RG_TGZ}"; \
    curl -sSLO "${RG_TGZ_URL}"; \
    tar -zxvf "${RG_TGZ}"; \
    mv "ripgrep-${RG_VERSION}-${RG_ARCH}"/rg /usr/local/bin/; \
    cd -; \
    rm -rf "${TEMP_DIR}"

## bat
RUN \
    TEMP_DIR="$(mktemp -d)"; \
    cd "${TEMP_DIR}"; \
    BAT_VERSION="0.18.3"; \
    BAT_ARCH="x86_64-unknown-linux-musl"; \
    BAT_TGZ="bat-v${BAT_VERSION}-${BAT_ARCH}.tar.gz"; \
    BAT_TGZ_URL="https://github.com/sharkdp/bat/releases/download/v${BAT_VERSION}/${BAT_TGZ}"; \
    curl -sSLO "${BAT_TGZ_URL}"; \
    tar -zxvf "${BAT_TGZ}"; \
    mv "bat-v${BAT_VERSION}-${BAT_ARCH}"/bat /usr/local/bin/; \
    cd -; \
    rm -rf "${TEMP_DIR}"

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
DAGGER_VERSION="v0.12.3"
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

## kubectl
RUN <<EOF
set -euf -o pipefail
KUBECTL_VERSION="v1.25.5"

curl -L https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl -o /usr/bin/kubectl
chmod +x /usr/bin/kubectl
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


COPY --chown=0:0 entrypoint.sh /
COPY --chown=0:0 .stow-local-ignore /home/tooling/

RUN \
    # add user and configure it
    useradd -u 1234 -G root -d /home/user --shell /bin/bash -m user && \
    echo "user ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/user &&\
    # Setup $PS1 for a consistent and reasonable prompt
    echo "export PS1='\W \`git branch --show-current 2>/dev/null | sed -r -e \"s@^(.+)@\(\1\) @\"\`$ '" >> /home/user/.bashrc && \
    echo 'eval "$(direnv hook bash)"' >> /home/user/.bashrc &&\
    # Copy the global git configuration to user config as global /etc/gitconfig
    #  file may be overwritten by a mounted file at runtime
    cp /etc/gitconfig ${HOME}/.gitconfig && \
    chown 1234 ${HOME}/ ${HOME}/.viminfo ${HOME}/.gitconfig ${HOME}/.stow-local-ignore && \
    # Set permissions on /etc/passwd and /home to allow arbitrary users to write
    chgrp -R 0 /home && \
    chmod -R g=u /etc/passwd /etc/group /home && \
    chmod +x /entrypoint.sh &&\
    # Create symbolic links from /home/tooling/ -> /home/user/
    stow . -t /home/user/ -d /home/tooling/ && \
    # .viminfo cannot be a symbolic link for security reasons, so copy it to /home/user/
    cp /home/tooling/.viminfo /home/user/.viminfo && \
    # Bash-related files are backed up to /home/tooling/ incase they are deleted when persistUserHome is enabled.
    cp /home/user/.bashrc /home/tooling/.bashrc && \
    cp /home/user/.bash_profile /home/tooling/.bash_profile && \
    chown 1234 /home/tooling/.bashrc /home/tooling/.bash_profile

# Define user directory for binaries
ENV PATH="/home/user/.local/bin:$PATH"

USER 1234
ENV HOME=/home/user

WORKDIR /projects
ENTRYPOINT [ "/entrypoint.sh" ]
CMD ["tail", "-f", "/dev/null"]
