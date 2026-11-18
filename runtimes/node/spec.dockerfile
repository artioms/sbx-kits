# syntax=docker/dockerfile:1

FROM --platform=$TARGETPLATFORM debian:trixie-slim AS downloader

ARG TARGETARCH
ARG NODE_MAJOR=24

RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
      ca-certificates \
      curl \
      tar \
      xz-utils \
      libatomic1; \
    rm -rf /var/lib/apt/lists/*

# Keep the supported LTS patch versions and their official SHA-256 values in sync.
RUN set -eux; \
    case "$NODE_MAJOR" in \
      22) \
        NODE_VERSION=22.23.5; \
        case "$TARGETARCH" in \
          amd64) NODE_ARCH=x64; NODE_SHA256=cdeb8670a0c81f51b4dc4ac61919f9b1ad917b304bf8221eb939570663d240f8 ;; \
          arm64) NODE_ARCH=arm64; NODE_SHA256=2babb9eb5264860d540849f4b064a6fbdebcdc323657d9d382ce23d313fd5e09 ;; \
          *) echo "Unsupported architecture: $TARGETARCH"; exit 1 ;; \
        esac ;; \
      24) \
        NODE_VERSION=24.22.3; \
        case "$TARGETARCH" in \
          amd64) NODE_ARCH=x64; NODE_SHA256=4f2b175a6d53a5c617a80dba2676238a0688cef28c6da4eba35c7d844e66fcfb ;; \
          arm64) NODE_ARCH=arm64; NODE_SHA256=6e51a2ada00f0011cc266f65d98922b403d7ad88f809ca2aa615a5fe1ce6e86c ;; \
          *) echo "Unsupported architecture: $TARGETARCH"; exit 1 ;; \
        esac ;; \
      26) \
        NODE_VERSION=26.13.1; \
        case "$TARGETARCH" in \
          amd64) NODE_ARCH=x64; NODE_SHA256=5c063e46bab0fbc1c17cc445d7ff129cbdcd0471be6ed83b6ab864f8143bc864 ;; \
          arm64) NODE_ARCH=arm64; NODE_SHA256=89e1853138db51e8b82d3e98ba9c0d3f2956a28e5e55ea1b7e12d25aae92d5dd ;; \
          *) echo "Unsupported architecture: $TARGETARCH"; exit 1 ;; \
        esac ;; \
      *) echo "Unsupported Node.js LTS major: $NODE_MAJOR (supported: 22, 24, 26)"; exit 1 ;; \
    esac; \
    mkdir -p /out/opt/node /out/usr/local/bin /out/usr/lib; \
    curl -fsSL \
      "https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-${NODE_ARCH}.tar.xz" \
      -o /tmp/node.tar.xz; \
    echo "${NODE_SHA256}  /tmp/node.tar.xz" | sha256sum -c -; \
    tar -xJf /tmp/node.tar.xz \
      -C /out/opt/node --strip-components=1; \
    ln -s /opt/node/bin/node /out/usr/local/bin/node; \
    ln -s /opt/node/bin/npm /out/usr/local/bin/npm; \
    ln -s /opt/node/bin/npx /out/usr/local/bin/npx; \
    atomic_lib="$(ldconfig -p | awk '$1 == "libatomic.so.1" { print $NF; exit }')"; \
    test -n "$atomic_lib"; \
    cp -L "$atomic_lib" /out/usr/lib/libatomic.so.1

# Export only the required files
FROM scratch

COPY --from=downloader /out/ /
