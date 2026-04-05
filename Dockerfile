# syntax=docker/dockerfile:1

FROM ghcr.io/linuxserver/baseimage-selkies:debiantrixie

# set version label
ARG BUILD_DATE
ARG GHDESKTOP_VERSION
ARG VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="thelamer"

# title
ENV TITLE=Github-Desktop \
    NO_GAMEPAD=true \
    NO_FULL=true \
    SELKIES_DESKTOP=true \
    PIXELFLUX_WAYLAND=true

RUN \
  echo "**** add icon ****" && \
  curl -o \
    /usr/share/selkies/www/icon.png \
    https://raw.githubusercontent.com/linuxserver/docker-templates/master/linuxserver.io/img/github-desktop-icon.png && \
  echo "**** install packages ****" && \
  apt-get update && \
  apt-get install --no-install-recommends -y \
    caja \
    chromium \
    chromium-l10n \
    git \
    ssh-askpass \
    xfce4-terminal && \
  echo "**** install github-desktop ****" && \
  if [ -z ${GHDESKTOP_VERSION+x} ]; then \
    GHDESKTOP_VERSION=$(curl -sX GET "https://api.github.com/repos/shiftkey/desktop/releases/latest" \
    | awk '/tag_name/{print $4;exit}' FS='[""]'); \
  fi && \
  curl -o \
    /tmp/ghdesktop.deb -L \
    "https://github.com/shiftkey/desktop/releases/download/${GHDESKTOP_VERSION}/GitHubDesktop-linux-amd64-${GHDESKTOP_VERSION#release-}.deb" && \
  apt install --no-install-recommends -y /tmp/ghdesktop.deb && \
  echo "**** install codium ****" && \
  CODIUM_VERSION=$(curl -sX GET "https://api.github.com/repos/VSCodium/vscodium/releases/latest" \
  | awk '/tag_name/{print $4;exit}' FS='[""]'); \
  curl -o \
    /tmp/codium.deb -L \
    "https://github.com/VSCodium/vscodium/releases/download/${CODIUM_VERSION}/codium_${CODIUM_VERSION}_amd64.deb" && \
  apt install --no-install-recommends -y /tmp/codium.deb && \
  sed -i \
    's:/usr/share/codium/codium:/usr/bin/codium:g' \
    /usr/share/applications/codium.desktop && \
  echo "**** container tweaks ****" && \
  ln -s \
    /usr/bin/xfce4-terminal \
    /usr/bin/gnome-terminal && \
  mv \
    /usr/bin/chromium \
    /usr/bin/chromium-real && \
  echo "**** cleanup ****" && \
  apt-get autoclean && \
  rm -rf \
    /tmp/* \
    /usr/share/applications/caja-autorun-software.desktop \
    /usr/share/applications/caja-computer.desktop \
    /usr/share/applications/caja.desktop \
    /usr/share/applications/caja-file-management-properties.desktop \
    /usr/share/applications/caja-folder-handler.desktop \
    /usr/share/applications/caja-home.desktop \
    /usr/share/applications/codium-url-handler.desktop \
    /usr/share/applications/debian-uxterm.desktop \
    /usr/share/applications/debian-xterm.desktop \
    /usr/share/applications/footclient.desktop \
    /usr/share/applications/foot-server.desktop \
    /usr/share/applications/mate-about.desktop \
    /usr/share/applications/mate-color-select.desktop \
    /usr/share/applications/st.desktop \
    /usr/share/applications/xfce4-terminal-settings.desktop \
    /var/lib/apt/lists/* \
    /var/tmp/*

# add local files
COPY /root /

# ports and volumes
EXPOSE 3000

VOLUME /config
