# syntax=docker/dockerfile:1
FROM --platform=$TARGETPLATFORM ubuntu:22.04 AS build

USER root

# Build against Ubuntu 22.04's glibc 2.35 baseline for compatibility with
# older sandbox images. Keep the runtime's libc, loader, and libtinfo.
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
      binutils \
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
    : > /tmp/tool-libraries; \
    # ldd reports each binary's full recursive dependency tree.
    for binary in /out/opt/tools/bin/*; do \
      if ! ldd "$binary" > /tmp/tool-ldd; then \
        echo "ldd failed for $binary" >&2; exit 1; \
      fi; \
      if grep -q 'not found' /tmp/tool-ldd; then \
        echo "Unresolved shared-library dependency for $binary:" >&2; cat /tmp/tool-ldd >&2; exit 1; \
      fi; \
      awk '$2 == "=>" && $3 ~ /^\// { print $3 } $1 ~ /^\// { print $1 }' /tmp/tool-ldd >> /tmp/tool-libraries; \
    done; \
    sort -u /tmp/tool-libraries -o /tmp/tool-libraries; \
    : > /tmp/tool-copy-libraries; \
    while IFS= read -r library; do \
      test -f "$library" || { echo "Resolved library does not exist: $library" >&2; exit 1; }; \
      case "$(basename "$library")" in \
        libc.so.*|libm.so.*|libpthread.so.*|libdl.so.*|librt.so.*|libresolv.so.*|libutil.so.*|libtinfo.so.*|ld-linux*.so.*|ld-musl*.so.*) continue ;; \
      esac; \
      printf '%s\n' "$library" >> /tmp/tool-copy-libraries; \
    done < /tmp/tool-libraries; \
    if ! awk '{ name = $0; sub(/^.*\//, "", name); if (name in paths && paths[name] != $0) { printf "Library basename collision for %s: %s and %s\n", name, paths[name], $0; failed = 1 } else paths[name] = $0 } END { if (failed) exit 1 }' /tmp/tool-copy-libraries; then \
      exit 1; \
    fi; \
    while IFS= read -r library; do \
      install -m 0644 "$library" "/out/opt/tools/lib/$(basename "$library")"; \
    done < /tmp/tool-copy-libraries; \
    check_symbol_versions() { \
      artifact="$1"; \
      if ! readelf --version-info "$artifact" > /tmp/tool-version-info; then \
        echo "readelf failed for $artifact" >&2; exit 1; \
      fi; \
      symbols="$(grep -oE '(GLIBC|GLIBCXX|CXXABI|GCC)_[0-9]+(\.[0-9]+)+' /tmp/tool-version-info || true)"; \
      for symbol in $symbols; do \
        case "$symbol" in \
          GLIBC_*) prefix=GLIBC_; maximum=2.35 ;; \
          GLIBCXX_*) prefix=GLIBCXX_; maximum=3.4.30 ;; \
          CXXABI_*) prefix=CXXABI_; maximum=1.3.13 ;; \
          GCC_*) prefix=GCC_; maximum=11.0 ;; \
        esac; \
        version="${symbol#"$prefix"}"; \
        newest="$(printf '%s\n' "$maximum" "$version" | sort -V | tail -n 1)"; \
        if [ "$newest" != "$maximum" ]; then \
          echo "$artifact requires $symbol; maximum supported is ${prefix}${maximum}" >&2; exit 1; \
        fi; \
      done; \
    }; \
    for artifact in /out/opt/tools/bin/* /out/opt/tools/lib/*; do \
      check_symbol_versions "$artifact"; \
    done; \
    for utility in less jq rg fd; do \
      printf '#!/bin/sh\nexport LD_LIBRARY_PATH=/opt/tools/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}\nexec /opt/tools/bin/%s "$@"\n' "$utility" \
        > "/out/usr/local/bin/$utility"; \
      chmod 0755 "/out/usr/local/bin/$utility"; \
    done; \
    ln -s less /out/usr/local/bin/pager

FROM scratch

COPY --from=build /out/ /
