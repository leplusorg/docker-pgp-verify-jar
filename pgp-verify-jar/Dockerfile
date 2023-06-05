FROM alpine:3.18.0

# hadolint ignore=DL3018
RUN apk --update --no-cache add bash curl gnupg \
    && rm -rf /var/cache/apk/* \
    && gpgconf --list-dirs

COPY pgp-verify-jar.sh /opt/pgp-verify-jar.sh

ENTRYPOINT ["/opt/pgp-verify-jar.sh"]
