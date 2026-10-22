# pgp-verify-jar image

Build context for the `leplusorg/pgp-verify-jar` container image. See the
[root readme](../README.md) for what the image does and how to run it.

## Files

- `Dockerfile` — the image definition. Its entrypoint is `pgp-verify-jar.sh`.
  System packages come from the base distribution's package manager and are
  pinned to exact versions here.
- `docker-compose.test.yml` — the test run in CI against the built image: the
  `sut` service verifies the signatures of two known artifacts against their
  expected keys.
- `pgp-verify-jar.sh` — the entrypoint. It downloads jars and their PGP
  signatures from a Maven repository (Maven Central by default), given
  Gradle-style coordinates, and verifies them with keys fetched from a keyserver
  or read from a local key store. Run it with `-h` for its options.

This image has no package manifest: everything in it comes from the base
distribution's package manager, at the versions pinned in the `Dockerfile`.
