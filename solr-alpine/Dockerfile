
FROM adoptopenjdk/openjdk13:alpine-jre

LABEL maintainer="Webdev \"webdev@jud.ca.gov\""

# ssh
ENV SSH_PASSWD "root:Docker!"
ENV SSH_PORT 2222

ARG SOLR_VERSION="8.5.1"
ARG SOLR_SHA512="b372f44baeafa12ec9c06239080e04c75328c37c92e5d27e6f819b139a69eacbbb879d73f032b20db66d33ee33efb41283648727a169ce4edf67095b780a5d0c"
ARG SOLR_KEYS="E58A6F4D5B2B48AC66D5E53BD4F181881A42F9E6"
# If specified, this will override SOLR_DOWNLOAD_SERVER and all ASF mirrors. Typically used downstream for custom builds
ARG SOLR_DOWNLOAD_URL

# Override the solr download location with e.g.:
#   docker build -t mine --build-arg SOLR_DOWNLOAD_SERVER=http://www-eu.apache.org/dist/lucene/solr .
ARG SOLR_DOWNLOAD_SERVER

RUN apk add --no-cache \
        acl \
        bash \
        gnupg \
        lsof \
        procps \
        tar \
        sudo

RUN apk add --no-cache ca-certificates wget && \
        update-ca-certificates

ENV SOLR_USER="solr" \
    SOLR_UID="8983" \
    SOLR_GROUP="solr" \
    SOLR_GID="8983" \
    SOLR_CLOSER_URL="http://www.apache.org/dyn/closer.lua?filename=lucene/solr/$SOLR_VERSION/solr-$SOLR_VERSION.tgz&action=download" \
    SOLR_DIST_URL="https://www.apache.org/dist/lucene/solr/$SOLR_VERSION/solr-$SOLR_VERSION.tgz" \
    SOLR_ARCHIVE_URL="https://archive.apache.org/dist/lucene/solr/$SOLR_VERSION/solr-$SOLR_VERSION.tgz" \
    PATH="/opt/solr/bin:/opt/docker-solr/scripts:$PATH" \
    SOLR_INCLUDE=/etc/default/solr.in.sh \
    SOLR_HOME=/var/solr/data \
    SOLR_PID_DIR=/var/solr \
    SOLR_LOGS_DIR=/var/solr/logs \
    LOG4J_PROPS=/var/solr/log4j2.xml

ENV GOSU_VERSION 1.11
ENV GOSU_KEY B42F6819007F00F88E364FD4036A9C25BF357DD4

ENV TINI_VERSION v0.18.0
ENV TINI_KEY 595E85A6B1B4779EA4DAAEC70B588DFF0527A9B7

RUN addgroup -S -g "$SOLR_GID" "$SOLR_GROUP" && \
    adduser -S -u "$SOLR_UID" -G "$SOLR_GROUP" "$SOLR_USER";

RUN set -ex; \
  export GNUPGHOME="/tmp/gnupg_home"; \
  mkdir -p "$GNUPGHOME"; \
  chmod 700 "$GNUPGHOME"; \
  echo "disable-ipv6" >> "$GNUPGHOME/dirmngr.conf"; \
  for key in $SOLR_KEYS $GOSU_KEY $TINI_KEY; do \
    found=''; \
    for server in \
      ha.pool.sks-keyservers.net \
      hkp://keyserver.ubuntu.com:80 \
      hkp://p80.pool.sks-keyservers.net:80 \
      pgp.mit.edu \
    ; do \
      echo "  trying $server for $key"; \
      gpg --batch --keyserver "$server" --keyserver-options timeout=10 --recv-keys "$key" && found=yes && break; \
      gpg --batch --keyserver "$server" --keyserver-options timeout=10 --recv-keys "$key" && found=yes && break; \
    done; \
    test -z "$found" && echo >&2 "error: failed to fetch $key from several disparate servers -- network issues?" && exit 1; \
  done; \
  exit 0

RUN set -ex; \
  export GNUPGHOME="/tmp/gnupg_home"; \
  pkgArch="$(apk --print-arch | sed 's/x86_64/amd64/' | sed 's/aarch64/arm64/')"; \
  wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$pkgArch"; \
  wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$pkgArch.asc"; \
  gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu; \
  rm /usr/local/bin/gosu.asc; \
  chmod +x /usr/local/bin/gosu; \
  gosu nobody true; \
  wget -O /usr/local/bin/tini "https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini-$pkgArch"; \
  wget -O /usr/local/bin/tini.asc "https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini-$pkgArch.asc"; \
  gpg --batch --verify /usr/local/bin/tini.asc /usr/local/bin/tini; \
  rm /usr/local/bin/tini.asc; \
  chmod +x /usr/local/bin/tini; \
  tini --version; \
  MAX_REDIRECTS=1; \
  if [ -n "$SOLR_DOWNLOAD_URL" ]; then \
    # If a custom URL is defined, we download from non-ASF mirror URL and allow more redirects and skip GPG step
    # This takes effect only if the SOLR_DOWNLOAD_URL build-arg is specified, typically in downstream Dockerfiles
    MAX_REDIRECTS=4; \
    SKIP_GPG_CHECK=true; \
  elif [ -n "$SOLR_DOWNLOAD_SERVER" ]; then \
    SOLR_DOWNLOAD_URL="$SOLR_DOWNLOAD_SERVER/$SOLR_VERSION/solr-$SOLR_VERSION.tgz"; \
  fi; \
  for url in $SOLR_DOWNLOAD_URL $SOLR_CLOSER_URL $SOLR_DIST_URL $SOLR_ARCHIVE_URL; do \
    if [ -f "/opt/solr-$SOLR_VERSION.tgz" ]; then break; fi; \
    echo "downloading $url"; \
    if wget -t 10 --max-redirect $MAX_REDIRECTS --retry-connrefused -nv "$url" -O "/opt/solr-$SOLR_VERSION.tgz"; then break; else rm -f "/opt/solr-$SOLR_VERSION.tgz"; fi; \
  done; \
  if [ ! -f "/opt/solr-$SOLR_VERSION.tgz" ]; then echo "failed all download attempts for solr-$SOLR_VERSION.tgz"; exit 1; fi; \
  if [ -z "$SKIP_GPG_CHECK" ]; then \
    echo "downloading $SOLR_ARCHIVE_URL.asc"; \
    wget -nv "$SOLR_ARCHIVE_URL.asc" -O "/opt/solr-$SOLR_VERSION.tgz.asc"; \
    echo "$SOLR_SHA512 */opt/solr-$SOLR_VERSION.tgz" | sha512sum -c -; \
    (>&2 ls -l "/opt/solr-$SOLR_VERSION.tgz" "/opt/solr-$SOLR_VERSION.tgz.asc"); \
    gpg --batch --verify "/opt/solr-$SOLR_VERSION.tgz.asc" "/opt/solr-$SOLR_VERSION.tgz"; \
  else \
    echo "Skipping GPG validation due to non-Apache build"; \
  fi; \
  tar -C /opt --extract --file "/opt/solr-$SOLR_VERSION.tgz"; \
  (cd /opt; ln -s "solr-$SOLR_VERSION" solr); \
  rm "/opt/solr-$SOLR_VERSION.tgz"*; \
  rm -Rf /opt/solr/docs/; \
  mkdir -p /opt/solr/server/solr/lib /docker-entrypoint-initdb.d /opt/docker-solr; \
  chown -R 0:0 "/opt/solr-$SOLR_VERSION"; \
  find "/opt/solr-$SOLR_VERSION" -type d -print0 | xargs -0 chmod 0755; \
  find "/opt/solr-$SOLR_VERSION" -type f -print0 | xargs -0 chmod 0644; \
  chmod -R 0755 "/opt/solr-$SOLR_VERSION/bin" "/opt/solr-$SOLR_VERSION/contrib/prometheus-exporter/bin/solr-exporter" /opt/solr-$SOLR_VERSION/server/scripts/cloud-scripts; \
  mkdir /etc/default; \
  chown root: /etc/default; \
  chmod 0755 /etc/default; \
  cp /opt/solr/bin/solr.in.sh /etc/default/solr.in.sh; \
  mv /opt/solr/bin/solr.in.sh /opt/solr/bin/solr.in.sh.orig; \
  mv /opt/solr/bin/solr.in.cmd /opt/solr/bin/solr.in.cmd.orig; \
  chown root:0 /etc/default/solr.in.sh; \
  chmod 0664 /etc/default/solr.in.sh; \
  mkdir -p /var/solr/data /var/solr/logs; \
  (cd /opt/solr/server/solr; cp solr.xml zoo.cfg /var/solr/data/); \
  cp /opt/solr/server/resources/log4j2.xml /var/solr/log4j2.xml; \
  find /var/solr -type d -print0 | xargs -0 chmod 0770; \
  find /var/solr -type f -print0 | xargs -0 chmod 0660; \
  sed -i -e "s/\"\$(whoami)\" == \"root\"/\$(id -u) == 0/" /opt/solr/bin/solr; \
  sed -i -e 's/lsof -PniTCP:/lsof -t -PniTCP:/' /opt/solr/bin/solr; \
  chown -R "0:0" /opt/solr-$SOLR_VERSION /docker-entrypoint-initdb.d /opt/docker-solr; \
  chown -R "$SOLR_USER:0" /var/solr; \
  { command -v gpgconf; gpgconf --kill all || :; }; \
  rm -r "$GNUPGHOME"

COPY --chown=0:0 scripts /opt/docker-solr/scripts

# ------
# ssh
# ------

RUN chmod +x /opt/docker-solr/scripts/init-azure.sh && \
    echo 'solr ALL=(root) NOPASSWD:SETENV: /opt/docker-solr/scripts/init-azure.sh' > /etc/sudoers.d/solr && \
    chmod 0440 /etc/sudoers.d/solr;

RUN set -ex; \
    apk add --no-cache openssh-server \
    && echo "$SSH_PASSWD" | chpasswd \
#---------------
# openrc service
#---------------
   && apk add --no-cache openrc \
   && sed -i 's/"cgroup_add_service/" # cgroup_add_service/g' /lib/rc/sh/openrc-run.sh \
# ~. upgrade/clean up
	&& apk upgrade \
	&& rm -rf /var/cache/apk/* \
    && rm -rf /tmp/*
COPY config/sshd_config /etc/ssh/

# Configsets
COPY configsets /opt/solr/server/solr/configsets/

#VOLUME /var/solr
EXPOSE 2222 8983
WORKDIR /opt/solr
USER $SOLR_USER

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["solr-foreground"]
