# syntax=docker/dockerfile:1.3-labs

FROM quay.io/webcenter/developer-image:base-ubi9-latest

#labels for container catalog
LABEL summary="Golang developer image"
LABEL description="Image to develop with go"
LABEL io.k8s.display-name="Golang"


USER 0
ENV HOME=/home/tooling

# Go
RUN dnf install -y gcc
ENV GOPATH /go
ENV PATH /usr/local/go/bin:$GOPATH/bin:$PATH

RUN <<EOF
set -euf -o pipefail
GO_VERSION=1.24.0
mkdir -p /go /usr/local/go
curl -o- -L https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz | tar xz -C /usr/local/go --strip-components=1
chmod -R 777 /go

go install github.com/acroca/go-symbols@latest &&\
go install github.com/cweill/gotests/gotests@latest &&\
go install github.com/davidrjenni/reftools/cmd/fillstruct@latest &&\
go install github.com/haya14busa/goplay/cmd/goplay@latest &&\
go install github.com/stamblerre/gocode@latest &&\
mv /usr/local/go/bin/gocode /usr/local/go/bin/gocode-gomod &&\
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
cd /usr/local/go && wget -O- -nv https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s v1.63.4
EOF

USER 10001
ENV HOME=/home/user
