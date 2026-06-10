FROM alpine:3.24.0@sha256:a2d49ea686c2adfe3c992e47dc3b5e7fa6e6b5055609400dc2acaeb241c829f4

HEALTHCHECK NONE

ARG USER_NAME=default
ARG USER_HOME=/home/default
ARG USER_ID=1000
ARG USER_GECOS=Default

SHELL ["/bin/ash", "-euo", "pipefail", "-c"]

RUN apk upgrade --no-cache \
    && apk add --no-cache \
    bash=5.3.3-r1 \
    curl=8.19.0-r0 \
    git=2.52.0-r0 \
    gnupg=2.4.9-r0 \
    && apk cache --no-cache clean \
    && rm -rf /var/cache/apk/*
    
# create gpg directory to prevent keyboxd to automagically start, see https://github.com/nodejs/docker-node/pull/1895#issuecomment-1550389150
RUN mkdir -m 700 /root/.gnupg \
    && gpg --list-keys \
    && gpgconf --kill all

RUN mkdir -m 777 /tmp/pgp-verify-jar

COPY pgp-verify-jar.sh /opt/pgp-verify-jar.sh

RUN chmod ugo+rx /opt/pgp-verify-jar.sh

RUN adduser \
  --home "${USER_HOME}" \
  --uid "${USER_ID}" \
  --gecos "${USER_GECOS}" \
  --disabled-password \
  "${USER_NAME}"

USER "${USER_NAME}"

ENV HOME="${USER_HOME}"

WORKDIR "${HOME}"

ENTRYPOINT ["/opt/pgp-verify-jar.sh"]

CMD []
