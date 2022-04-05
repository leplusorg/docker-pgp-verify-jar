FROM alpine:3.15.4

# hadolint ignore=DL3018
RUN apk --update --no-cache add bash curl gnupg \
    && rm -rf /var/cache/apk/* \
    && gpg --list-keys

COPY pgp-verify-jar.sh /opt/pgp-verify-jar.sh

ENTRYPOINT ["/bin/bash", "/opt/pgp-verify-jar.sh"]
