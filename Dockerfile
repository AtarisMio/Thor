FROM ubuntu:20.04 AS builder
RUN DEBIAN_FRONTEND=noninteractive apt-get -y update && \
    DEBIAN_FRONTEND=noninteractive apt-get -y install curl git xz-utils dpkg-dev
ARG VERSION=2.2.3
WORKDIR /work
COPY xunlei.amd64.spk /work/
RUN echo 'start' && \
    ls -l && \
    tar -xvf xunlei.$(dpkg-architecture  -q DEB_BUILD_ARCH).spk package.tgz && \
    rm -rf xunlei.spk && \
    tar -xvf package.tgz && \
    rm -rf package.tgz && \
    sed -i 's/mounts/status/' bin/bin/xunlei-pan-cli.${VERSION}.$(dpkg-architecture  -q DEB_BUILD_ARCH) && \
    sed -i 's/mounts/status/' ui/index.cgi && \
    mv bin/bin/xunlei-pan-cli-launcher.$(dpkg-architecture  -q DEB_BUILD_ARCH) bin/bin/xunlei-pan-cli-launcher && \
    mv ui/index.cgi bin/bin/xunlei-pan-cli-web && \
    echo 'done'

FROM golang:1.17.6 AS gobuilder
WORKDIR /go/src
COPY xunlei_cgi /go/src/xunlei_cgi
WORKDIR /go/src/xunlei_cgi
RUN go env -w GO111MODULE=on && go env -w GOPROXY=https://goproxy.cn,direct
RUN CGO_ENABLED=0 go build -a -ldflags '-extldflags "-static"' -v
RUN ls -alth 

FROM ubuntu:20.04
WORKDIR /tmp/go-build/pan-xunlei-com
COPY --from=builder /work/bin/bin/* /tmp/go-build/pan-xunlei-com/target/
COPY --from=gobuilder /go/src/xunlei_cgi/xunlei_cgi /tmp/go-build/pan-xunlei-com/xunlei_cgi
RUN echo 'start' && \
    mkdir -p /downloads && \
    mkdir -p /usr/syno/synoman/webman/modules && \
    echo '#!/usr/bin/env sh' > /usr/syno/synoman/webman/modules/authenticate.cgi && \
    echo 'echo dosk' >> /usr/syno/synoman/webman/modules/authenticate.cgi && \
    echo '{"port":5050, "internal": false, "dir":"/downloads"}' > /tmp/go-build/pan-xunlei-com/config.json && \
    chmod 755 /usr/syno/synoman/webman/modules/authenticate.cgi && \
    mkdir -p /var/packages/pan-xunlei-com/target/var && \
    mkdir -p /tmp/go-build/pan-xunlei-com/shares && \
    ln -s /tmp/go-build/pan-xunlei-com/target/var/pan-xunlei-com.sock /var/packages/pan-xunlei-com/target/var/pan-xunlei-com.sock && \
    ln -s /tmp/go-build/pan-xunlei-com/target/var/pan-xunlei-com-launcher.sock /var/packages/pan-xunlei-com/target/var/pan-xunlei-com-launcher.sock && \
    echo 'done'
ADD init /init
ENV UID=99 GID=100
EXPOSE 5050
VOLUME ["/downloads"]
ENTRYPOINT ["/init"]
