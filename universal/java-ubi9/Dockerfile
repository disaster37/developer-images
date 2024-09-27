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

USER 0

# $PROFILE_EXT contains all additions made to the bash environment
ENV PROFILE_EXT=/etc/profile.d/udi_environment.sh
RUN touch ${PROFILE_EXT} & chown 1234 ${PROFILE_EXT}


# Keep Go for dagger
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


# Java

USER 1234

# We install everything to /home/tooling/ as /home/user/ may get overriden, see github.com/eclipse/che/issues/22412
ENV HOME=/home/tooling

RUN curl -fsSL "https://get.sdkman.io/?rcupdate=false" | bash \
    && bash -c ". /home/tooling/.sdkman/bin/sdkman-init.sh \
             && sed -i "s/sdkman_auto_answer=false/sdkman_auto_answer=true/g" /home/tooling/.sdkman/etc/config \
	     && sed -i "s/sdkman_auto_env=false/sdkman_auto_env=true/g" /home/tooling/.sdkman/etc/config \
             && sdk install java 8.0.402-tem \
             && sdk install java 11.0.22-tem \
             && sdk install java 17.0.10-tem \
             && sdk install java 21.0.2-tem \
             && sdk install java 23.1.2.r21-mandrel \
             && sdk default java 17.0.10-tem \
             && sdk install gradle \
             && sdk install maven \
             && sdk install jbang \
             && sdk flush archives \
             && sdk flush temp" \
         && chgrp -R 0 /home/tooling && chmod -R g=u /home/tooling

# sdk home java <version>
ENV JAVA_HOME_8=/home/tooling/.sdkman/candidates/java/8.0.402-tem
ENV JAVA_HOME_11=/home/tooling/.sdkman/candidates/java/11.0.22-tem
ENV JAVA_HOME_17=/home/tooling/.sdkman/candidates/java/17.0.10-tem
ENV JAVA_HOME_21=/home/tooling/.sdkman/candidates/java/21.0.2-tem

# Java-related environment variables are described and set by ${PROFILE_EXT}, which will be loaded by ~/.bashrc
# To make Java working for dash and other shells, it needs to initialize them in the Dockerfile.
ENV SDKMAN_CANDIDATES_API="https://api.sdkman.io/2"
ENV SDKMAN_CANDIDATES_DIR="/home/tooling/.sdkman/candidates"
ENV SDKMAN_DIR="/home/tooling/.sdkman"
ENV SDKMAN_PLATFORM="linuxx64"
ENV SDKMAN_VERSION="5.18.2"

ENV GRADLE_HOME="/home/tooling/.sdkman/candidates/gradle/current"
ENV JAVA_HOME="/home/tooling/.sdkman/candidates/java/current"
ENV MAVEN_HOME="/home/tooling/.sdkman/candidates/maven/current"

ENV GRAALVM_HOME=/home/tooling/.sdkman/candidates/java/23.1.2.r21-mandrel

ENV PATH="/home/tooling/.krew/bin:$PATH"
ENV PATH="/home/tooling/.sdkman/candidates/maven/current/bin:$PATH"
ENV PATH="/home/tooling/.sdkman/candidates/java/current/bin:$PATH"
ENV PATH="/home/tooling/.sdkman/candidates/gradle/current/bin:$PATH"
ENV PATH="/home/tooling/.local/share/coursier/bin:$PATH"

# NodeJS
RUN mkdir -p /home/tooling/.nvm/
ENV NVM_DIR="/home/tooling/.nvm"
ENV NODEJS_20_VERSION=20.7.0
ENV NODEJS_18_VERSION=18.19.1
ENV NODEJS_DEFAULT_VERSION=${NODEJS_18_VERSION}
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh | PROFILE=/dev/null bash
RUN echo 'export NVM_DIR="$HOME/.nvm"' >> ${PROFILE_EXT} \
    && echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' >> ${PROFILE_EXT}
RUN source /home/user/.bashrc && \
    nvm install v${NODEJS_20_VERSION} && \
    nvm install v${NODEJS_18_VERSION} && \
    nvm alias default v${NODEJS_DEFAULT_VERSION} && nvm use v${NODEJS_DEFAULT_VERSION} && \
    npm install --global yarn@v1.22.17 &&\
    chgrp -R 0 /home/tooling && chmod -R g=u /home/tooling
ENV PATH=$NVM_DIR/versions/node/v${NODEJS_DEFAULT_VERSION}/bin:$PATH
ENV NODEJS_HOME_20=$NVM_DIR/versions/node/v${NODEJS_20_VERSION}
ENV NODEJS_HOME_18=$NVM_DIR/versions/node/v${NODEJS_18_VERSION}

USER 0

# Set permissions on /etc/passwd and /home to allow arbitrary users to write
RUN mkdir -p /home/user && chgrp -R 0 /home && chmod -R g=u /etc/passwd /etc/group /home

USER 1234

ENV HOME=/home/user
