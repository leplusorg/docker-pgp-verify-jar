FROM alpine:3.20.2@sha256:0a4eaa0eecf5f8c050e5bba433f58c052be7587ee8af3e8b3910ef9ab5fbe9f5

HEALTHCHECK NONE

ARG USER_NAME=default
ARG USER_HOME=/home/default
ARG USER_ID=1000
ARG USER_GECOS=Default

# hadolint ignore=DL3018
RUN apk --update --no-cache add bash curl gnupg \
    && rm -rf /var/cache/apk/* \
    # create gpg directory to prevent keyboxd to automagically start, see https://github.com/nodejs/docker-node/pull/1895#issuecomment-1550389150
    && mkdir /root/.gnupg \
    && chmod 700 /root/.gnupg \
    && gpg --list-keys \
    && gpgconf --kill all

COPY pgp-verify-jar.sh /opt/pgp-verify-jar.sh

RUN adduser \
  --home "${USER_HOME}" \
  --uid "${USER_ID}" \
  --gecos "${USER_GECOS}" \
  --disabled-password \
  "${USER_NAME}"

ENV HOME "${USER_HOME}"

USER "${USER_NAME}"

WORKDIR "${HOME}"

ENTRYPOINT ["/opt/pgp-verify-jar.sh"]
