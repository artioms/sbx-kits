# syntax=docker/dockerfile:1

FROM docker.io/sbx/shell-docker-image:latest AS build

ARG VERSION=1.5.2
ARG NODE_VERSION=24.22.3
ARG TARGETARCH

USER root

# Install download and extraction utilities (Debian)
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates curl xz-utils \
    && rm -rf /var/lib/apt/lists/*

# Download and verify official Node.js
RUN set -eux; \
    case "$TARGETARCH" in \
      amd64) \
        NODE_ARCH=x64; \
        NODE_SHA256=4f2b175a6d53a5c617a80dba2676238a0688cef28c6da4eba35c7d844e66fcfb ;; \
      arm64) \
        NODE_ARCH=arm64; \
        NODE_SHA256=6e51a2ada00f0011cc266f65d98922b403d7ad88f809ca2aa615a5fe1ce6e86c ;; \
      *) echo "Unsupported architecture: $TARGETARCH"; exit 1 ;; \
    esac; \
    mkdir -p /out/opt/node24 /out/usr/local/bin; \
    curl -fsSL \
      "https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-${NODE_ARCH}.tar.xz" \
      -o /tmp/node.tar.xz; \
    echo "${NODE_SHA256}  /tmp/node.tar.xz" | sha256sum -c -; \
    tar -xJf /tmp/node.tar.xz \
      -C /out/opt/node24 --strip-components=1

# Use this Node installation for npm during the build
ENV PATH="/out/opt/node24/bin:${PATH}"

# Install Pi
RUN npm install -g \
    --prefix /out/usr/local \
    --ignore-scripts \
    "@earendil-works/pi-coding-agent@${VERSION}"

# Create runtime entry points
RUN set -eux; \
    ln -s /opt/node24/bin/node /out/usr/local/bin/node; \
    ln -s /opt/node24/bin/npm /out/usr/local/bin/npm; \
    ln -s /opt/node24/bin/npx /out/usr/local/bin/npx

# Export only what the mixin needs
FROM scratch

COPY --from=build /out/opt/node24/ /opt/node24/
COPY --from=build /out/usr/local/ /usr/local/
