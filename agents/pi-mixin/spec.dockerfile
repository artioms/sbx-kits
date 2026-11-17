# syntax=docker/dockerfile:1
FROM docker.io/sbx/shell-docker-image:latest AS build

ARG VERSION=1.5.2

USER root

# Install Pi into an isolated staging directory
RUN npm install -g \
    --prefix /out/usr/local \
    --ignore-scripts \
    "@earendil-works/pi-coding-agent@${VERSION}"

# Export the Node.js runtime too
RUN set -eux; \
    node_bin="$(readlink -f "$(command -v node)")"; \
    install -D "$node_bin" /out/usr/local/bin/node

# Final mixin filesystem
FROM scratch

COPY --from=build /out/usr/local/ /usr/local/
