#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

for artifact in "$@"
do
    echo checking ${artifact}...
    IFS=':' read -ra coordinates <<< "${artifact}"
    groupId="${coordinates[0]}"
    artifactId="${coordinates[1]}"
    artifactVersion="${coordinates[2]}"
    curl -s -S -o "${artifactId}-${artifactVersion}.jar" "https://repo1.maven.org/maven2/${groupId}/${artifactId}/${artifactVersion}/${artifactId}-${artifactVersion}.jar"
    curl -s -S -o "${artifactId}-${artifactVersion}.jar.asc" "https://repo1.maven.org/maven2/${groupId}/${artifactId}/${artifactVersion}/${artifactId}-${artifactVersion}.jar.asc"
    gpg --auto-key-locate keyserver --keyserver pgp.mit.edu --keyserver-options auto-key-retrieve --verify "${artifactId}-${artifactVersion}.jar.asc" "${artifactId}-${artifactVersion}.jar"
done
