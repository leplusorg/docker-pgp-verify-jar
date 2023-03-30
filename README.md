# PGP Verify Jar

Docker container to verify jars PGP signatures.

[![ShellCheck](https://github.com/leplusorg/docker-pgp-verify-jar/workflows/ShellCheck/badge.svg)](https://github.com/leplusorg/docker-pgp-verify-jar/actions?query=workflow:"ShellCheck")
[![Docker Build](https://github.com/leplusorg/docker-pgp-verify-jar/workflows/Docker/badge.svg)](https://github.com/leplusorg/docker-pgp-verify-jar/actions?query=workflow:"Docker")
[![Docker Stars](https://img.shields.io/docker/stars/leplusorg/pgp-verify-jar)](https://hub.docker.com/r/leplusorg/pgp-verify-jar)
[![Docker Pulls](https://img.shields.io/docker/pulls/leplusorg/pgp-verify-jar)](https://hub.docker.com/r/leplusorg/pgp-verify-jar)
[![Docker Automated](https://img.shields.io/docker/cloud/automated/leplusorg/pgp-verify-jar)](https://hub.docker.com/r/leplusorg/pgp-verify-jar)
[![Docker Build](https://img.shields.io/docker/cloud/build/leplusorg/pgp-verify-jar)](https://hub.docker.com/r/leplusorg/pgp-verify-jar)
[![Docker Version](https://img.shields.io/docker/v/leplusorg/pgp-verify-jar?sort=semver)](https://hub.docker.com/r/leplusorg/pgp-verify-jar)

## Examples

Assuming that you want to see the signature of a jar with coordinates 'org.leplus:ristretto:1.0.0':

```bash
docker run --rm leplusorg/pgp-verify-jar org.leplus:ristretto:1.0.0
```

You can put several sets in coordinates in arguments to verify
multiple artifacts. You can also use the `KEYSERVER` environment
variable to choose a different keyserver (default is keyserver.ubuntu.com):

```bash
docker run --rm -e KEYSERVER=pgp.mit.edu leplusorg/pgp-verify-jar org.leplus:ristretto:1.0.0
```

Alternatively you can use the `--keyserver` option to achieve the same
result:

```bash
docker run --rm leplusorg/pgp-verify-jar --keyserver=pgp.mit.edu org.leplus:ristretto:1.0.0
```

Note that this will show you the jar's signature information but if
you use a public keyserver, it doesn't provide any guarantee since
anybody can upload a key to a public keyserver and claim that it is
owned by anyone (neither the name nor the email address associated
with the key are verified).

There are several solutions to this issue. If you have access to
private keyserver hosting only trusted keys, you can simply use the
`KEYSERVER` environment variable or the `--keyserver` option described
above.

Otherwise, you can use the `ONLINE_KEYS` environment variable to restrict the
keys to be trusted from the server (private or public). `ONLINE_KEYS`
should contain a coma-separated list of public key IDs:

```bash
docker run --rm -e ONLINE_KEYS=6B1B9BE54C155617,85911F425EC61B51 leplusorg/pgp-verify-jar org.leplus:ristretto:1.0.0 junit:junit:4.13.1
```

Alternatively you can use the `--online-keys` option to achieve the
same result:

```bash
docker run --rm leplusorg/pgp-verify-jar --online-keys=6B1B9BE54C155617,85911F425EC61B51 org.leplus:ristretto:1.0.0 junit:junit:4.13.1
```

If the keys downloaded from the server are themselves signed by
other keys, you can import these key-signing keys first using the
`BOOTSTRAP_ONLINE_KEYS` environment variable or the
`--bootstrap-online-keys` option (again a coma-separated list of
public key IDs in both cases).

Otherwise you will see the following warning from `gpg`:
`gpg: WARNING: This key is not certified with a trusted signature!`

Finally, if you prefer to verify signatures entirely offline, you can
mount a local GnuPG folder of your choice into the docker container
and setting the `VERIFICATION_MODE` environment variable to `offline`
(default value is `online`):

```bash
docker run --rm -e VERIFICATION_MODE=offline -v "/path/to/.gnupg:/root/.gnupg" leplusorg/pgp-verify-jar org.leplus:ristretto:1.0.0
```

Alternatively you can use the `--verification-mode` option to achieve
the same result:

```bash
docker run --rm -v "/path/to/.gnupg:/root/.gnupg" leplusorg/pgp-verify-jar --verification-mode=offline org.leplus:ristretto:1.0.0
```

In `offline` mode, all the keys present in the keyring can be used to
check the signatures. The keys cannot be restricted as with the
`ONLINE_KEYS` environment variable or the `--online-keys` option. But
the key ID used to verify each signature will be displayed in the
output so you can review them if needed. Or you can pass a keyring
containing only the acceptable keys.

In `offline` mode, you are also responsible for putting in the keyring
any key-signing key if needed.
