# syntax=docker/dockerfile:1
FROM docker.io/sbx/shell-docker-image:latest AS build

USER root

# Install against the shell's own userspace so exported tools remain compatible
# with the base image used when the kit is assembled.
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
      fd-find \
      jq \
      less \
      ripgrep; \
    rm -rf /var/lib/apt/lists/*

RUN set -eux; \
    mkdir -p /out/opt/tools/bin /out/opt/tools/lib /out/usr/local/bin; \
    install -m 0755 /usr/bin/less /out/opt/tools/bin/less; \
    install -m 0755 /usr/bin/jq /out/opt/tools/bin/jq; \
    install -m 0755 /usr/bin/rg /out/opt/tools/bin/rg; \
    install -m 0755 /usr/bin/fdfind /out/opt/tools/bin/fd; \
    for binary in /out/opt/tools/bin/*; do \
      ldd "$binary" | awk '/=> \/|^[[:space:]]*\// { for (i = 1; i <= NF; i++) if ($i ~ /^\//) { print $i; break } }'; \
    done | sort -u | while read -r library; do \
      case "$(basename "$library")" in \
        libc.so.*|libm.so.*|libpthread.so.*|libdl.so.*|librt.so.*|ld-linux*.so.*|ld-musl*.so.*) continue ;; \
      esac; \
      install -m 0644 "$library" "/out/opt/tools/lib/$(basename "$library")"; \
    done; \
    for utility in less jq rg fd; do \
      printf '#!/bin/sh\nexport LD_LIBRARY_PATH=/opt/tools/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}\nexec /opt/tools/bin/%s "$@"\n' "$utility" \
        > "/out/usr/local/bin/$utility"; \
      chmod 0755 "/out/usr/local/bin/$utility"; \
    done; \
    ln -s less /out/usr/local/bin/pager

FROM scratch

COPY --from=build /out/ /
