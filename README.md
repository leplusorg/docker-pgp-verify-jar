# PGP Verify Jar

Docker container to verify jars PGP signatures.

[![Docker Build](https://github.com/thomasleplus/docker-pgp-verify-jar/workflows/Docker/badge.svg)](https://github.com/thomasleplus/docker-pgp-verify-jar/actions?query=workflow:"Docker")
[![Docker Stars](https://img.shields.io/docker/stars/thomasleplus/pgp-verify-jar)](https://hub.docker.com/r/thomasleplus/pgp-verify-jar)
[![Docker Pulls](https://img.shields.io/docker/pulls/thomasleplus/pgp-verify-jar)](https://hub.docker.com/r/thomasleplus/pgp-verify-jar)
[![Docker Automated](https://img.shields.io/docker/cloud/automated/thomasleplus/pgp-verify-jar)](https://hub.docker.com/r/thomasleplus/pgp-verify-jar)
[![Docker Build](https://img.shields.io/docker/cloud/build/thomasleplus/pgp-verify-jar)](https://hub.docker.com/r/thomasleplus/pgp-verify-jar)
[![Docker Version](https://img.shields.io/docker/v/thomasleplus/pgp-verify-jar?sort=semver)](https://hub.docker.com/r/thomasleplus/pgp-verify-jar)

## Examples

Assuming that you want to see the signature of a jar with coordinates 'org.leplus:ristretto:1.0.0':

```
docker run --rm thomasleplus/pgp-verify-jar org.leplus:ristretto:1.0.0
```

You can put several sets in coordinates in arguments to verify
multiple artifacts. You can also use the `KEYSERVER` environment
variable to choose a different key server (default is keyserver.ubuntu.com):

```
docker run --rm -e KEYSERVER=pgp.mit.edu thomasleplus/pgp-verify-jar org.leplus:ristretto:1.0.0
```

Note that this will show you the jar's signature information but if
you use a public key server, it doesn't provide any guarantee since
anybody can upload a key to a public key server and claim that it is
owned by anyone (neither the name nor the email address associated
with the key are verified).

There are several solutions to this issue. If you have access to
private key server hosting only trusted keys, you can use with the
`KEYSERVER` environment variable described above.

Otherwise, you can use the `ONLINE_KEYS` environment variable to restrict the
keys to be trusted from the server (private or public). `ONLINE_KEYS`
should contain a coma-separated list of public key IDs:

```
docker run --rm -e ONLINE_KEYS=6B1B9BE54C155617,85911F425EC61B51 thomasleplus/pgp-verify-jar org.leplus:ristretto:1.0.0 junit:junit:4.13.1
```

Finally, if you prefer to verify signatures entirely offline, you can
mount a local GnuPG folder of your choice into the docker container
and setting the `OFFLINE_KEYS` environment variable to any value:

```
docker run --rm -e OFFLINE_KEYS=1 -v "/path/to/.gnupg:/root/.gnupg" thomasleplus/pgp-verify-jar org.leplus:ristretto:1.0.0
```

The `OFFLINE_KEYS` environment variable cannot be used to restrict the
keys to be used from the mounted keyring. All keys can be used to
check the signatures but the key ID matching each signature will be
displayed so you can review it if needed.
