# PGP Verify Jar

Multi-platform Docker container to verify JAR files PGP signatures.

[![Dockerfile](https://img.shields.io/badge/GitHub-Dockerfile-blue)](pgp-verify-jar/Dockerfile)
[![ShellCheck](https://github.com/leplusorg/docker-pgp-verify-jar/workflows/ShellCheck/badge.svg)](https://github.com/leplusorg/docker-pgp-verify-jar/actions?query=workflow:"ShellCheck")
[![Docker Build](https://github.com/leplusorg/docker-pgp-verify-jar/workflows/Docker/badge.svg)](https://github.com/leplusorg/docker-pgp-verify-jar/actions?query=workflow:"Docker")
[![Docker Stars](https://img.shields.io/docker/stars/leplusorg/pgp-verify-jar)](https://hub.docker.com/r/leplusorg/pgp-verify-jar)
[![Docker Pulls](https://img.shields.io/docker/pulls/leplusorg/pgp-verify-jar)](https://hub.docker.com/r/leplusorg/pgp-verify-jar)
[![Docker Version](https://img.shields.io/docker/v/leplusorg/pgp-verify-jar?sort=semver)](https://hub.docker.com/r/leplusorg/pgp-verify-jar)
[![CII Best Practices](https://bestpractices.coreinfrastructure.org/projects/10079/badge)](https://bestpractices.coreinfrastructure.org/projects/10079)
[![OpenSSF Scorecard](https://api.securityscorecards.dev/projects/github.com/leplusorg/docker-pgp-verify-jar/badge)](https://securityscorecards.dev/viewer/?uri=github.com/leplusorg/docker-pgp-verify-jar)

## Goal and limitations

The goal of this Docker container image is to provide an easy way to
verify JAR files signatures. Currently it can only verify files that
it downloads from a Maven repository that doesn't require
authentication and that use a certificate issues by a trusted public
CA.

This image has the benefit of being platform-agnostic and it
doesn't rely on Maven or Java. But if your goal is to validate
signatures for your project dependencies at build time and/or runtime,
there are Maven plugins (e.g.
[Verify PGP signatures](https://www.simplify4u.org/pgpverify-maven-plugin/)).
Gradle even has this feature
[out-of-the-box](https://docs.gradle.org/current/userguide/dependency_verification.html).

## Examples

Assuming that you want to see the signature of two JAR files:

```bash
docker run --rm leplusorg/pgp-verify-jar org.leplus:ristretto:2.0.0 junit:junit:4.13.1
```

You can also use the `ARTIFACTS` environment
variable to pass the list of artifacts to verify (coma-separated if
multiple):

```bash
docker run --rm -e ARTIFACTS=org.leplus:ristretto:2.0.0,junit:junit:4.13.1 leplusorg/pgp-verify-jar
```

You can also use the `KEYSERVER` environment
variable to choose a different keyserver (default is keyserver.ubuntu.com):

```bash
docker run --rm -e KEYSERVER=pgp.mit.edu leplusorg/pgp-verify-jar org.leplus:ristretto:2.0.0 junit:junit:4.13.1
```

Alternatively you can use the `--keyserver` option to achieve the same
result:

```bash
docker run --rm leplusorg/pgp-verify-jar --keyserver=pgp.mit.edu org.leplus:ristretto:2.0.0 junit:junit:4.13.1
```

> [!WARNING]
> Note that this will show you the JAR files signature information but if
> you use a public keyserver, it doesn't provide any guarantee since
> anybody can upload a key to a public keyserver and claim that it is
> owned by anyone (neither the name nor the email address associated
> with the key are verified).

There are several solutions to this issue. If you have access to
private keyserver hosting only trusted keys, you can simply use the
`KEYSERVER` environment variable or the `--keyserver` option described
above.

Otherwise, you can use the `ONLINE_KEYS` environment variable to restrict the
keys to be trusted from the server (private or public). `ONLINE_KEYS`
should contain a coma-separated list of public key IDs:

```bash
docker run --rm -e ONLINE_KEYS=6B1B9BE54C155617,85911F425EC61B51 leplusorg/pgp-verify-jar org.leplus:ristretto:2.0.0 junit:junit:4.13.1
```

Alternatively you can use the `--online-keys` option to achieve the
same result:

```bash
docker run --rm leplusorg/pgp-verify-jar --online-keys=6B1B9BE54C155617,85911F425EC61B51 org.leplus:ristretto:2.0.0 junit:junit:4.13.1
```

If the keys downloaded from the server are themselves signed by
other keys, you can import these key-signing keys first using the
`BOOTSTRAP_ONLINE_KEYS` environment variable or the
`--bootstrap-online-keys` option (again a coma-separated list of
public key IDs in both cases).

Otherwise you will see the following warning from `gpg`:
`gpg: WARNING: This key is not certified with a trusted signature!`

Finally, if you prefer to verify signatures entirely offline, you can
mount a local GnuPG directory of your choice into the Docker container
and setting the `VERIFICATION_MODE` environment variable to `offline`
(default value is `online`):

```bash
docker run --rm -e VERIFICATION_MODE=offline -v "/path/to/.gnupg:/home/default/.gnupg" leplusorg/pgp-verify-jar org.leplus:ristretto:2.0.0 junit:junit:4.13.1
```

Alternatively you can use the `--verification-mode` option to achieve
the same result:

```bash
docker run --rm -v "/path/to/.gnupg:/home/default/.gnupg" leplusorg/pgp-verify-jar --verification-mode=offline org.leplus:ristretto:2.0.0 junit:junit:4.13.1
```

In `offline` mode, all the keys present in the keyring can be used to
check the signatures. The keys cannot be restricted as with the
`ONLINE_KEYS` environment variable or the `--online-keys` option. But
the key ID used to verify each signature will be displayed in the
output so you can review them if needed. Or you can pass a keyring
containing only the acceptable keys.

In `offline` mode, you are also responsible for putting in the keyring
any key-signing key if needed.

## Software Bill of Materials (SBOM)

To get the SBOM for the latest image (in SPDX JSON format), use the
following command:

```bash
docker buildx imagetools inspect leplusorg/pgp-verify-jar --format '{{ json (index .SBOM "linux/amd64").SPDX }}'
```

Replace `linux/amd64` by the desired platform (`linux/amd64`, `linux/arm64` etc.).

### Sigstore

[Sigstore](https://docs.sigstore.dev) is trying to improve supply
chain security by allowing you to verify the origin of an
artifcat. You can verify that the image that you use was actually
produced by this repository. This means that if you verify the
signature of the Docker image, you can trust the integrity of the
whole supply chain from code source, to CI/CD build, to distribution
on Maven Central or whever you got the image from.

You can use the following command to verify the latest image using its
sigstore signature attestation:

```bash
cosign verify leplusorg/pgp-verify-jar --certificate-identity-regexp 'https://github\.com/leplusorg/docker-pgp-verify-jar/\.github/workflows/.+' --certificate-oidc-issuer 'https://token.actions.githubusercontent.com'
```

The output should look something like this:

```text
Verification for index.docker.io/leplusorg/xml:main --
The following checks were performed on each of these signatures:
  - The cosign claims were validated
  - Existence of the claims in the transparency log was verified offline
  - The code-signing certificate was verified using trusted certificate authority certificates

[{"critical":...
```

For instructions on how to install `cosign`, please read this [documentation](https://docs.sigstore.dev/cosign/system_config/installation/).
