# syntax=docker/dockerfile:1
FROM docker.io/sbx/shell-docker-image:latest AS build

ARG VERSION=1.5.2

USER root

# Install Pi into an isolated staging directory
RUN npm install -g \
    --prefix /out/usr/local \
    --ignore-scripts \
    "@earendil-works/pi-coding-agent@${VERSION}"

# Final mixin filesystem
FROM scratch

COPY --from=build /out/usr/local/ /usr/local/