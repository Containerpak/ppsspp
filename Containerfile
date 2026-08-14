FROM ubuntu:26.04 AS source

ADD --checksum=sha256:661c098e6b7f7610171a57b7c533ce8bba6f2312b71e76d61e850461973eba21 https://github.com/hrydgard/ppsspp/releases/download/v1.20.4/PPSSPP-v1.20.4-anylinux-x86_64.AppImage /tmp/source

RUN chmod 0755 /tmp/source && \
    cd /tmp && \
    ./source --appimage-extract >/dev/null && \
    mkdir -p /stage && \
    cp -a /tmp/squashfs-root/. /stage/

FROM ghcr.io/containerpak/mesa64:main

LABEL org.opencontainers.image.source="https://github.com/Containerpak/ppsspp"

COPY --from=source /stage/ /opt/ppsspp/
COPY ppsspp /usr/bin/ppsspp
COPY org.ppsspp.PPSSPP.desktop /usr/share/applications/org.ppsspp.PPSSPP.desktop

RUN chmod 0755 /usr/bin/ppsspp && \
    if [ -e /opt/ppsspp/.DirIcon ]; then install -Dm644 /opt/ppsspp/.DirIcon /usr/share/icons/hicolor/256x256/apps/org.ppsspp.PPSSPP.png; fi && \
    cpak-clean-junk
