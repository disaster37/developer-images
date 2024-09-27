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

USER 0


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
RUN curl -fsSL "https://get.sdkman.io/?rcupdate=false" | bash \
    && bash -c ". /home/user/.sdkman/bin/sdkman-init.sh \
             && sed -i "s/sdkman_auto_answer=false/sdkman_auto_answer=true/g" /home/user/.sdkman/etc/config \
	     && sed -i "s/sdkman_auto_env=false/sdkman_auto_env=true/g" /home/user/.sdkman/etc/config \
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
         && chgrp -R 0 /home/user && chmod -R g=u /home/user

# sdk home java <version>
ENV JAVA_HOME_8=/home/user/.sdkman/candidates/java/8.0.402-tem
ENV JAVA_HOME_11=/home/user/.sdkman/candidates/java/11.0.22-tem
ENV JAVA_HOME_17=/home/user/.sdkman/candidates/java/17.0.10-tem
ENV JAVA_HOME_21=/home/user/.sdkman/candidates/java/21.0.2-tem

# Java-related environment variables are described and set by ${PROFILE_EXT}, which will be loaded by ~/.bashrc
# To make Java working for dash and other shells, it needs to initialize them in the Dockerfile.
ENV SDKMAN_CANDIDATES_API="https://api.sdkman.io/2"
ENV SDKMAN_CANDIDATES_DIR="/home/user/.sdkman/candidates"
ENV SDKMAN_DIR="/home/user/.sdkman"
ENV SDKMAN_PLATFORM="linuxx64"
ENV SDKMAN_VERSION="5.18.2"

ENV GRADLE_HOME="/home/user/.sdkman/candidates/gradle/current"
ENV JAVA_HOME="/home/user/.sdkman/candidates/java/current"
ENV MAVEN_HOME="/home/user/.sdkman/candidates/maven/current"

ENV GRAALVM_HOME=/home/user/.sdkman/candidates/java/23.1.2.r21-mandrel

ENV PATH="/home/user/.krew/bin:$PATH"
ENV PATH="/home/user/.sdkman/candidates/maven/current/bin:$PATH"
ENV PATH="/home/user/.sdkman/candidates/java/current/bin:$PATH"
ENV PATH="/home/user/.sdkman/candidates/gradle/current/bin:$PATH"
ENV PATH="/home/user/.local/share/coursier/bin:$PATH"



# Set permissions on /etc/passwd and /home to allow arbitrary users to write
RUN mkdir -p /home/user && chgrp -R 0 /home && chmod -R g=u /etc/passwd /etc/group /home

USER 1234
