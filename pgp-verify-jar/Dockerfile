FROM alpine:3.22.1@sha256:4bcff63911fcb4448bd4fdacec207030997caf25e9bea4045fa6c8c44de311d1

HEALTHCHECK NONE

ARG USER_NAME=default
ARG USER_HOME=/home/default
ARG USER_ID=1000
ARG USER_GECOS=Default

SHELL ["/bin/ash", "-euo", "pipefail", "-c"]

# hadolint ignore=DL3019
RUN apk upgrade --no-cache \
    && apk add --no-cache \
    bash=5.2.37-r0 \
    curl=8.14.1-r1 \
    git=2.49.1-r0 \
    gnupg=2.4.7-r0 \
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
