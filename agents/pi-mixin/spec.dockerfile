FROM docker.io/sbx/shell-docker-image:latest AS build

ARG VERSION=1.5.2

USER root

RUN npm install -g \
    --prefix /out/usr/local \
    --ignore-scripts \
    "@earendil-works/pi-coding-agent@${VERSION}"

FROM scratch

COPY --from=build /out/usr/local/ /usr/local/