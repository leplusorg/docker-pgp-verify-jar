# PGP Verify Jar

Docker container to verify jars PGP signatures.

[![Docker Build](https://github.com/thomasleplus/docker-pgp-verify-jar/workflows/Docker/badge.svg)](https://github.com/thomasleplus/docker-pgp-verify-jar/actions?query=workflow:"Docker")
[![Docker Stars](https://img.shields.io/docker/stars/thomasleplus/pgp-verify-jar)](https://hub.docker.com/r/thomasleplus/pgp-verify-jar)
[![Docker Pulls](https://img.shields.io/docker/pulls/thomasleplus/pgp-verify-jar)](https://hub.docker.com/r/thomasleplus/pgp-verify-jar)
[![Docker Automated](https://img.shields.io/docker/cloud/automated/thomasleplus/pgp-verify-jar)](https://hub.docker.com/r/thomasleplus/pgp-verify-jar)
[![Docker Build](https://img.shields.io/docker/cloud/build/thomasleplus/pgp-verify-jar)](https://hub.docker.com/r/thomasleplus/pgp-verify-jar)
[![Docker Version](https://img.shields.io/docker/v/thomasleplus/pgp-verify-jar?sort=semver)](https://hub.docker.com/r/thomasleplus/pgp-verify-jar)

## Example

Assuming that you want to verify the signature of a jar with coordinates 'foo:bar:1.2.3':

```
docker run --rm thomasleplus/pgp-verify-jar foo:bar:1.2.3
```
