FROM ubuntu:26.04 AS source

ARG APP_SHA256=661c098e6b7f7610171a57b7c533ce8bba6f2312b71e76d61e850461973eba21

RUN apt-get update && \
    apt-get install -y --no-install-recommends ca-certificates curl && \
    curl --fail --location --output /tmp/PPSSPP-v1.20.4-anylinux-x86_64.AppImage "https://github.com/hrydgard/ppsspp/releases/download/v1.20.4/PPSSPP-v1.20.4-anylinux-x86_64.AppImage" && \
    echo "${APP_SHA256}  /tmp/PPSSPP-v1.20.4-anylinux-x86_64.AppImage" | sha256sum --check

FROM ghcr.io/containerpak/mesa:main

LABEL org.opencontainers.image.source="https://github.com/Containerpak/ppsspp"

COPY --from=source /tmp/PPSSPP-v1.20.4-anylinux-x86_64.AppImage /tmp/PPSSPP-v1.20.4-anylinux-x86_64.AppImage
COPY ppsspp /usr/bin/ppsspp
COPY org.ppsspp.PPSSPP.desktop /usr/share/applications/org.ppsspp.PPSSPP.desktop

RUN apt-get update && \
    apt-get install -y --no-install-recommends squashfs-tools && \
    chmod +x /tmp/PPSSPP-v1.20.4-anylinux-x86_64.AppImage && \
    /tmp/PPSSPP-v1.20.4-anylinux-x86_64.AppImage --appimage-extract && \
    mv squashfs-root /opt/ppsspp && \
    chmod 0755 /usr/bin/ppsspp && \
    if [ -e /opt/ppsspp/.DirIcon ]; then install -Dm644 /opt/ppsspp/.DirIcon /usr/share/icons/hicolor/256x256/apps/org.ppsspp.PPSSPP.png; fi && \
    rm -rf /tmp/PPSSPP-v1.20.4-anylinux-x86_64.AppImage /tmp/archive && \
    cpak-clean-junk

