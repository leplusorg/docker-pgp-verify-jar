FROM alpine:3.18.0

# hadolint ignore=DL3018,SC2155
RUN apk --update --no-cache add bash curl gnupg \
    && rm -rf /var/cache/apk/* \
    # use pre-existing gpg directory, see https://github.com/nodejs/docker-node/pull/1895#issuecomment-1550389150
    && mkdir /root/.gnupg \
    && gpg --list-keys \
    && gpgconf --kill all

COPY pgp-verify-jar.sh /opt/pgp-verify-jar.sh

ENTRYPOINT ["/opt/pgp-verify-jar.sh"]
