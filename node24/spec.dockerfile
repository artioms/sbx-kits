# syntax=docker/dockerfile:1

FROM alpine:3.22 AS downloader

ARG TARGETARCH
ARG NODE_VERSION=24.22.2

RUN apk add --no-cache curl tar xz

# Keep NODE_VERSION and these upstream SHA-256 values in sync.
RUN set -eux; \
    case "$TARGETARCH" in \
      amd64) \
        NODE_ARCH=x64; \
        NODE_SHA256=48cc0e21e048790e54c0cf5749c2725005313d652651c40b7a21feb9697aaf75 ;; \
      arm64) \
        NODE_ARCH=arm64; \
        NODE_SHA256=eb187837a2230d4047161ac0be008584e16b46f726e9c9490ee35dc6b17d9ba8 ;; \
      *) echo "Unsupported architecture: $TARGETARCH"; exit 1 ;; \
    esac; \
    mkdir -p /out/opt/node24 /out/usr/local/bin; \
    curl -fsSL \
      "https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-${NODE_ARCH}.tar.xz" \
      -o /tmp/node.tar.xz; \
    echo "${NODE_SHA256}  /tmp/node.tar.xz" | sha256sum -c -; \
    tar -xJf /tmp/node.tar.xz \
      -C /out/opt/node24 --strip-components=1; \
    ln -s /opt/node24/bin/node /out/usr/local/bin/node; \
    ln -s /opt/node24/bin/npm /out/usr/local/bin/npm; \
    ln -s /opt/node24/bin/npx /out/usr/local/bin/npx

FROM scratch

COPY --from=downloader /out/ /
