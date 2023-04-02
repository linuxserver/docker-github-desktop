FROM ghcr.io/linuxserver/baseimage-kasmvnc:debianbullseye

# set version label
ARG BUILD_DATE
ARG GHDESKTOP_VERSION
ARG VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="thelamer"

RUN \
  echo "**** install packages ****" && \
  apt-get update && \
  apt-get install --no-install-recommends -y \
    chromium \
    git \
    gnome-keyring \
    gvfs-bin \
    kde-cli-tools \
    libatk1.0-0 \
    libatk-bridge2.0-0 \
    libatspi2.0-0 \
    libcups2 \
    libglib2.0-0 \
    libglib2.0-bin \
    libgtk-3-0 \
    libnotify4 \
    libnspr4 \
    libnss3 \
    libsecret-1-0 \
    libxtst6 \
    ssh-askpass \
    thunar \
    trash-cli \
    xfce4-terminal && \
  echo "**** install github-desktop ****" && \
  if [ -z ${GHDESKTOP_VERSION+x} ]; then \
    GHDESKTOP_VERSION=$(curl -sX GET "https://api.github.com/repos/shiftkey/desktop/releases/latest" \
    | awk '/tag_name/{print $4;exit}' FS='[""]'); \
  fi && \
  curl -o \
    /tmp/ghdesktop.deb -L \
    "https://github.com/shiftkey/desktop/releases/download/${GHDESKTOP_VERSION}/GitHubDesktop-linux-${GHDESKTOP_VERSION#release-}.deb" && \
  dpkg -i /tmp/ghdesktop.deb && \
  echo "**** install codium ****" && \
  CODIUM_VERSION=$(curl -sX GET "https://api.github.com/repos/VSCodium/vscodium/releases/latest" \
  | awk '/tag_name/{print $4;exit}' FS='[""]'); \
  curl -o \
    /tmp/codium.deb -L \
    "https://github.com/VSCodium/vscodium/releases/download/${CODIUM_VERSION}/codium_${CODIUM_VERSION}_amd64.deb" && \
  dpkg -i /tmp/codium.deb && \
  echo "**** container tweaks ****" && \
  ln -s \
    /usr/bin/xfce4-terminal \
    /usr/bin/gnome-terminal && \
  mv \
    /usr/bin/chromium \
    /usr/bin/chromium-real && \
  sed -i 's|</applications>|  <application title="GitHub Desktop" type="normal">\n    <maximized>yes</maximized>\n  </application>\n</applications>|' /etc/xdg/openbox/rc.xml && \
  echo "**** cleanup ****" && \
  apt-get autoclean && \
  rm -rf \
    /var/lib/apt/lists/* \
    /var/tmp/* \
    /tmp/*

# add local files
COPY /root /

# ports and volumes
EXPOSE 3000

VOLUME /config
