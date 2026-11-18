# syntax=docker/dockerfile:1
FROM docker.io/sbx/shell-docker-image:latest AS build

ARG VERSION=1.19.6

USER root

# Install OpenCode and its platform-specific executable
RUN npm install -g \
    --prefix /out/usr/local \
    "opencode-ai@${VERSION}"

# Final mixin filesystem
FROM scratch

COPY --from=build /out/usr/local/ /usr/local/
